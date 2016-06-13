class Contact < ActiveRecord::Base
  attr_accessible :name, :phone1, :phone2, :email, :notes, :client_id, :crm_object_id, :location_id
  
  belongs_to :location
  
  validates :name, presence: true
  validates :name, uniqueness: true
  validates :email, format: { with: /\A[a-zA-Z0-9.\-_]+@[a-zA-Z0-9\-_]+\.[a-zA-Z]+\Z/, message: "is not a valid email address" }
end
