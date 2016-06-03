class Technician < ActiveRecord::Base
  attr_accessible :team_id, :first_name, :last_name, :friendly_name, :sharp_name, :car_stock_number, :email, :crm_id, :remember_me, :admin, :manager
  
  has_many :primary_devices, :dependent => :nullify, :class_name => 'Device', :foreign_key => 'primary_tech_id'
  has_many :backup_devices, :dependent => :nullify, :class_name => 'Device', :foreign_key => 'backup_tech_id'
  has_many :readings, :dependent => :nullify
  has_many :logs
  belongs_to :team, :foreign_key => :team_id
  has_one :preference, :dependent => :destroy
  
  validates :crm_id, :email, :first_name, :last_name, presence: true
  validates :crm_id, numericality: true
  validates :crm_id, :email, uniqueness: true
  validates :email, format: { with: /\A[a-zA-Z0-9.\-_]+@[a-zA-Z0-9\-_]+\.[a-zA-Z]+\Z/, message: "is not a valid email address" }
  validates_associated :team
  
  def find_contacts(filter = [], sort_attribute = :name, direction = 'asc', territory = true)
    contacts = []
    unless territory
      self.team.locations.find_each do |loc|
        contacts += loc.contacts.where(filter)
      end
    else
      if filter.nil?
        filter = ['devices.primary_tech_id = ?']
      else
        filter[0] += ' and devices.primary_tech_id = ?'
      end
      filter << self.id
      Location.joins(:devices,:contacts).where(filter).find_each do |loc|
        contacts += loc.contacts
      end
    end
    if direction =~ /desc/i
      contacts.sort_by(&sort_attribute).uniq.reverse
    else
      contacts.sort_by(&sort_attribute).uniq
    end
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
    if self.admin?
      true
    elsif self.manager?
      self.team_id == device.team_id
    else
      device.primary_tech_id == self.id or device.backup_tech_id == self.id
    end
  end
    
end
