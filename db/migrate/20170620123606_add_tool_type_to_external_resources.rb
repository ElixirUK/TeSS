class AddToolTypeToExternalResources < ActiveRecord::Migration
  def change
    add_column :external_resources, :tool_type, :string #, array: true, default: [] # Should an array be needed rather than a string...
  end
end
