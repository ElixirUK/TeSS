class Prerequisite < ApplicationRecord
  extend ActiveSupport::Concern

  belongs_to :resource, polymorphic: true

  validates :noun, controlled_vocabulary: { dictionary: NounDictionary.instance }
  validates :verb, controlled_vocabulary: { dictionary: VerbDictionary.instance }
end
