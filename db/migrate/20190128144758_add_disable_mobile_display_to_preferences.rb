class AddDisableMobileDisplayToPreferences < ActiveRecord::Migration[5.2]
  def change
    add_column :preferences, :mobile, :boolean, default: true
  end
end
