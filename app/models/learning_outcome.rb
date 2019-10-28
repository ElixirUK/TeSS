class LearningOutcome < ApplicationRecord

  include LearningStatement

  def matching_prerequisites
    return Prerequisite.where(verb: self.verb, noun: self.noun)
               .collect{|prereq| prereq.resource}.uniq
               .reject{|resource| resource == self.resource}
  end
end
