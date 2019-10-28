class AddTimestampsToLearningOutcomes < ActiveRecord::Migration[5.2]
  def change
    add_column :learning_outcomes, :created_at, :datetime, null: false
    add_column :learning_outcomes, :updated_at, :datetime, null: false
  end
end
