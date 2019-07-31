class Prerequisite < ApplicationRecord
  extend ActiveSupport::Concern

  belongs_to :resource, polymorphic: true

  validates :noun, controlled_vocabulary: { dictionary: NounDictionary.instance }
  validates :verb, controlled_vocabulary: { dictionary: VerbDictionary.instance }

  def matching_learning_outcomes
    return LearningOutcome.where(verb: self.verb, noun: self.noun)
               .collect{|outcome| outcome.resource}.uniq
               .reject{|resource| resource == self.resource}
  end


end
