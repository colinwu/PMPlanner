class Client < ApplicationRecord
  
  has_many :locations, dependent: :nullify
  has_many :contacts, dependent: :nullify
  
  validates :name, presence: true
end
