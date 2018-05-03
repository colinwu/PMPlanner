class Contact < ApplicationRecord
  
  belongs_to :location
  belongs_to :client
  
  validates :name, presence: true
  # validates :name, uniqueness: true
  validates_associated :location
  validates :email, format: { with: /\A[a-zA-Z0-9.\-_]+@[a-zA-Z0-9\-_]+\.[a-zA-Z]+\Z/, message: 'is not a valid email address' }, unless: Proc.new { |a| a.email.blank? }
end
