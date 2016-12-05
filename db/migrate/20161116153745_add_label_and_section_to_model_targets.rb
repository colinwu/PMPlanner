class AddLabelAndSectionToModelTargets < ActiveRecord::Migration
  def change
    add_column :model_targets, :label, :string
    add_column :model_targets, :section, :string
  end
end
