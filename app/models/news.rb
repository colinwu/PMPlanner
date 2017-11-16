class News < ActiveRecord::Base
  has_many :unreads, dependent: :destroy
  has_many :technicians, through: :unreads
  attr_accessible :note, :activate, :urgent
end
