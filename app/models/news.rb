class News < ApplicationRecord
  has_many :unreads, dependent: :destroy
  has_many :technicians, through: :unreads
end
