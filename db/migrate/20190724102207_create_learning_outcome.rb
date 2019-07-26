class CreateLearningOutcome < ActiveRecord::Migration[5.2]
  def change
    create_table :learning_outcomes do |t|
      t.string :verb
      t.string :noun
      t.references :resource, polymorphic: true, index: true
    end
  end
end
