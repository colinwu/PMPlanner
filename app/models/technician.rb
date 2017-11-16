class Technician < ActiveRecord::Base
  attr_accessible :team_id, :first_name, :last_name, :friendly_name, :sharp_name, :car_stock_number, :email, :crm_id, :remember_me, :admin, :manager, :current_sign_in_at, :current_sign_in_ip
  
  has_many :primary_devices, :dependent => :nullify, :class_name => 'Device', :foreign_key => 'primary_tech_id'
  has_many :backup_devices, :dependent => :nullify, :class_name => 'Device', :foreign_key => 'backup_tech_id'
  has_many :readings, :dependent => :nullify
  has_many :logs
  has_many :teams, :class_name => 'Team', :foreign_key => 'manager_id'
  has_many :unreads, dependent: :destroy
  has_many :news, through: :unreads
  belongs_to :team, :foreign_key => :team_id
  has_one :preference, :dependent => :destroy
  
  validates :crm_id, :email, :first_name, :last_name, presence: true
  validates :crm_id, numericality: true
  validates :crm_id, :friendly_name, uniqueness: true
  validates :email, format: { with: /\A[a-zA-Z0-9.\-_]+@[a-zA-Z0-9\-_]+\.[a-zA-Z]+\Z/, message: "is not a valid email address" }
  validates_associated :team
  
  def find_contacts(filter = [], sort_attribute = 'name', direction = 'asc', territory = true, page = 1)
    unless territory # Look in team territory
      loc_list = Location.where("team_id = #{self.team_id}").map{|l| l.id}.join(', ')
      if loc_list.blank?
        return Contact.where("id = -1")
      end
      if filter.empty?
        filter = "location_id in (#{loc_list})"
      else
        filter[0] += " and location_id in (#{loc_list})"
      end
      contacts = Contact.joins(:location).where(filter).order("#{sort_attribute} #{direction}").page(page)
    else  # Look only in own territory
      loc_list = Location.joins(:devices).where("devices.primary_tech_id = #{self.id}").map{|l| l.id}.join(', ')
      if loc_list.blank?
        return Contact.where("id = -1")
      end
      if filter.empty?
        filter = "location_id in (#{loc_list})"
      else
        filter[0] += " and location_id in (#{loc_list})"
      end
      contacts = Contact.joins(:location).where(filter).order("#{sort_attribute} #{direction}").page(page).per_page(lpp)
    end
    return contacts
  end
  
  def my_techs
    if self.manager?
      self.team.technicians
    elsif self.admin?
      Technician.all
    else
      nil
    end
  end
  
  def can_manage?(device)
    # turns out techs need to be able to search and record data for all devices in inventory
    return true
#     if self.admin?
#       true
#     elsif self.manager?
#       self.team_id == device.team_id
#     else
#       device.primary_tech_id == self.id or device.backup_tech_id == self.id
#     end
  end
      
  def get_manager
    self.team.manager
  end
  
  def full_name
    "#{self.first_name} #{self.last_name}"
  end
    
end
