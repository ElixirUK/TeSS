# This migration comes from tate (originally 20151013094203)
class CreateTateModels < ActiveRecord::Migration
    def self.up
      create_table :tate_annotations, :force => true do |t|
        t.string    :source_type,         :null => false
        t.integer   :source_id,           :null => false
        t.string    :annotatable_type,    :limit => 50, :null => false
        t.integer   :annotatable_id,      :null => false
        t.integer   :attribute_id,        :null => false
        t.string    :old_value,           :null => true
        t.string    :value_type,          :limit => 50, :null => false, :default => "Tate::TextValue"
        t.integer   :value_id,            :null => false, :default => 0
        t.integer   :version,             :null => false
        t.integer   :version_creator_id,  :null => true
        t.timestamps
      end

      add_index :tate_annotations, [ :value_type, :value_id ]
      add_index :tate_annotations, [ :source_type, :source_id ]
      add_index :tate_annotations, [ :annotatable_type, :annotatable_id ]
      add_index :tate_annotations, [ :attribute_id ]

      create_table :tate_annotation_versions, :force => true do |t|
        t.integer   :annotation_id,       :null => false
        t.integer   :version,             :null => false
        t.integer   :version_creator_id,  :null => true
        t.string    :source_type,         :null => false
        t.integer   :source_id,           :null => false
        t.string    :annotatable_type,    :limit => 50, :null => false
        t.integer   :annotatable_id,      :null => false
        t.integer   :attribute_id,        :null => false
        t.string    :old_value,              :null => true
        t.string    :value_type,          :limit => 50, :null => false, :default => "Tate::TextValue"
        t.integer   :value_id,            :null => false, :default => 0
        t.timestamps
      end

      add_index :tate_annotation_versions, [ :annotation_id ]

      create_table :tate_annotation_attributes, :force => true do |t|
        t.string :name, :null => false
        t.string :identifier, :null => false
        t.timestamps
      end

      add_index :tate_annotation_attributes, [ :name, :identifier ]

      create_table :tate_annotation_value_seeds, :force => true do |t|
        t.integer :attribute_id,      :null => false
        t.string  :old_value,  :null => true
        t.string  :tate_annotation_attributes, :identifier, :null => false
        t.string  :value_type, :limit => 50, :null => false, :default => "FIXME"
        t.integer :value_id, :null => false, :default => 0

        t.timestamps
      end

      add_index :tate_annotation_value_seeds, [ :attribute_id ]

      create_table :tate_text_values, :force => true do |t|
        t.integer :version, :null => false
        t.integer :version_creator_id, :null => true
        t.text :text, :limit => 16777214, :null => false
        t.timestamps
      end

      create_table :tate_text_value_versions, :force => true do |t|
        t.integer :text_value_id, :null => false
        t.integer :version, :null => false
        t.integer :version_creator_id, :null => true
        t.text :text, :limit => 16777214, :null => false
        t.timestamps
      end
      add_index :tate_text_value_versions, [ :text_value_id ]

      create_table :tate_number_values, :force => true do |t|
        t.integer :version, :null => false
        t.integer :version_creator_id, :null => true
        t.integer :number, :null => false
        t.timestamps
      end

      create_table :tate_number_value_versions, :force => true do |t|
        t.integer :number_value_id, :null => false
        t.integer :version, :null => false
        t.integer :version_creator_id, :null => true
        t.integer :number, :null => false
        t.timestamps
      end
      add_index :tate_number_value_versions, [ :number_value_id ]

    end

    def self.down
      drop_table :tate_annotations
      drop_table :tate_annotation_versions
      drop_table :tate_annotation_attributes
      drop_table :tate_annotation_value_seeds
    end
end