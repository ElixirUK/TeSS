class AddSuggestionsToCurationTask < ActiveRecord::Migration[5.2]
  def change
    add_column :curation_tasks, :update_fields, :text, default: ""
    add_column :curation_tasks, :message, :text, default: ""
  end
end