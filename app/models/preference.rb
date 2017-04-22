class Preference < ActiveRecord::Base
  attr_accessible :limit_to_region, :limit_to_territory, :previous_pm, :data_entry_date_prompt, :data_entry_notes_prompt, :default_notes, :select_territory, :territory_to_explore, :default_units_to_show, :upcoming_interval, :use_default_email, :default_to_email, :default_subject, :default_from_email, :default_message, :default_sig, :max_lines, :email_edit, :popup_equip_list, :technician_id, :lines_per_page, :default_root_path, :showbackup, :radius
  
  belongs_to :technician
end
