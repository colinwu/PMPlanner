class Client < ActiveRecord::Base
  attr_accessible :name, :address, :address2, :city, :province, :postal_code, :notes, :soldtoid
  
  has_many :locations, :dependent => :nullify
  has_many :ship_tos, :dependent => :nullify
  has_many :sold_tos, :dependent => :nullify
  has_many :contacts, :dependent => :nullify
  
  validates :name, presence: true
end
