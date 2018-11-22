class Location < ApplicationRecord
  
  has_many :devices, :dependent => :restrict_with_error
  has_many :contacts, :dependent => :nullify
  belongs_to :client
  belongs_to :team, :foreign_key => :team_id, optional: true
  
  validates :address1, :city, :province, :post_code, presence: true
  
  def to_s
    if self.address2.nil? or self.address2.empty?
      [self.address1.titleize, self.city.titleize, self.province, self.post_code.upcase].join(', ')
    else
      [self.address1.titleize, self.address2.titleize, self.city.titleize, self.province, self.post_code.upcase].join(', ')
    end
  end
end
