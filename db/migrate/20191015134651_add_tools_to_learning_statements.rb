class AddToolsToLearningStatements < ActiveRecord::Migration[5.2]
  def change
    add_column :prerequisites, :tool_id, :string
    add_column :prerequisites, :tool_name, :string
    add_column :learning_outcomes, :tool_id, :string
    add_column :learning_outcomes, :tool_name, :string
  end
end
