class AddShowFlagToNews < ActiveRecord::Migration
  def change
    add_column :news, :show_flag, :boolean, default: true
  end
end
