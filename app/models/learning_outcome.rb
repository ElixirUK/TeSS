class LearningOutcome < ApplicationRecord
  extend ActiveSupport::Concern

  belongs_to :resource, polymorphic: true

  validates :noun, controlled_vocabulary: { dictionary: NounDictionary.instance }
  validates :verb, controlled_vocabulary: { dictionary: VerbDictionary.instance }

  def matching_prerequisites
    return Prerequisite.where(verb: self.verb, noun: self.noun)
               .collect{|prereq| prereq.resource}.uniq
               .reject{|resource| resource == self.resource}
  end
end
