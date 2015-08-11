class AddLinePerPageToPreferences < ActiveRecord::Migration
  def change
    add_column :preferences, :lines_per_page, :integer
  end
end
