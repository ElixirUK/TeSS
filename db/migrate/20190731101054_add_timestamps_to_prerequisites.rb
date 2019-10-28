class AddTimestampsToPrerequisites< ActiveRecord::Migration[5.2]
  def change
    add_column :prerequisites, :created_at, :datetime, null: false
    add_column :prerequisites, :updated_at, :datetime, null: false
  end
end
