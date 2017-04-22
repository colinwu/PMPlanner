class AddRadiusToPreference < ActiveRecord::Migration
  def change
    add_column :preferences, :radius, :string
  end
end
