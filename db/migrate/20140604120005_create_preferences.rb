class CreatePreferences < ActiveRecord::Migration
  def self.up
    create_table :preferences do |t|
      t.boolean :zoom
      t.integer :zoom_level
      t.integer :zoom_start
      t.boolean :limit_to_region
      t.boolean :limit_to_territory
      t.boolean :previous_pm
      t.boolean :data_entry_date_prompt
      t.boolean :data_entry_notes_prompt
      t.text :default_notes
      t.boolean :select_territory
      t.string :territory_to_explore
      t.string :default_units_to_show
      t.integer :upcoming_interval
      t.boolean :use_default_email
      t.string :default_to_email
      t.string :default_subject
      t.string :default_from_email
      t.text :default_message
      t.string :default_sig
      t.integer :max_lines
      t.boolean :email_edit
      t.boolean :popup_equip_list
      t.integer :technician_id
      t.timestamps
    end
  end

  def self.down
    drop_table :preferences
  end
end
