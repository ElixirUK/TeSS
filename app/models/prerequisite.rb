class Prerequisite < ApplicationRecord

  include LearningStatement

  def matching_learning_outcomes
    return LearningOutcome.where(verb: self.verb, noun: self.noun)
               .collect{|outcome| outcome.resource}.uniq
               .reject{|resource| resource == self.resource}
  end

end
