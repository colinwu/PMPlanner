class CleanupPreferencesTables < ActiveRecord::Migration
  def change
    remove_column :preferences, :limit_to_region, :boolean
    remove_column :preferences, :limit_to_territory, :boolean
    remove_column :preferences, :previous_pm, :boolean
    remove_column :preferences, :data_entry_date_prompt, :boolean
    remove_column :preferences, :data_entry_notes_prompt, :boolean
    remove_column :preferences, :select_territory, :boolean
    remove_column :preferences, :territory_to_explore, :string
    remove_column :preferences, :use_default_email, :boolean
    remove_column :preferences, :email_edit, :boolean
  end
end
