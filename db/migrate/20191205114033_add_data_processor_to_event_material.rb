class AddDataProcessorToEventMaterial < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :data_processor_list, :string, array: true, default: []
    add_column :materials, :data_processor_list, :string, array: true, default: []
  end
end