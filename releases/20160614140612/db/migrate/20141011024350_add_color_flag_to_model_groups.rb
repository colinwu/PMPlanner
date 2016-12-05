class AddColorFlagToModelGroups < ActiveRecord::Migration
  def change
    add_column :model_groups, :color_flag, :boolean
  end
end
