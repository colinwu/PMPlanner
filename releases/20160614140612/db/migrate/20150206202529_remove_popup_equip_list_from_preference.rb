class RemovePopupEquipListFromPreference < ActiveRecord::Migration
  def change
    remove_column :preferences, :popup_equip_list, :string
  end
end
