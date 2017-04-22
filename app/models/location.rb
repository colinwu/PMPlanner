class Location < ActiveRecord::Base
  attr_accessible :address1, :address2, :city, :province, :post_code, :notes, :shiptoid, :client_id, :team_id
  
  has_many :devices, :dependent => :nullify
  has_many :contacts, :dependent => :nullify
  has_many :ship_tos, :dependent => :nullify
  belongs_to :client
  belongs_to :team, :foreign_key => :team_id
  
  validates :address1, :city, :province, :post_code, presence: true
  geocoded_by :geo_address
  after_validation :geocode, if: ->(obj){obj.geo_address.present? and obj.latitude.nil?}
  
  def geo_address
    if (not address1.nil? and address1.present?) and (not city.nil? and city.present?) and (not province.nil? and province.present?)
      [address1,city,province].compact.join(', ')
    else
      ''
    end
  end
  
  def to_s
    if self.address2.nil? or self.address2.empty?
      [self.address1.titleize, self.city.titleize, self.province, self.post_code.upcase].join(', ')
    else
      [self.address1.titleize, self.address2.titleize, self.city.titleize, self.province, self.post_code.upcase].join(', ')
    end
  end
end
