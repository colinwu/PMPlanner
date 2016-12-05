class Client < ActiveRecord::Base
  attr_accessible :name, :address, :address2, :city, :province, :postal_code, :notes, :soldto_id
  
  has_many :locations, :dependent => :nullify
  has_many :ship_tos, :dependent => :nullify
  has_many :sold_tos, :dependent => :nullify
  
  validates :name, presence: true
end
