class AddShowFlagToNews < ActiveRecord::Migration[4.2]
  def change
    add_column :news, :show_flag, :boolean, default: true
  end
end
