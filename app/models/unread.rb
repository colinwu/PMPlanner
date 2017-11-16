class Unread < ActiveRecord::Base
  belongs_to :technician
  belongs_to :news
  
  validates :technician_id, presence: true
  validates :news_id, presence: true
  
  attr_accessible :technician_id, :news_id
end
