class Preference < ActiveRecord::Base
  attr_accessible :default_notes, :default_units_to_show, :upcoming_interval, :default_to_email, :default_subject, :default_from_email, :default_message, :default_sig, :max_lines, :technician_id, :lines_per_page, :default_root_path, :showbackup
  
  belongs_to :technician
end
