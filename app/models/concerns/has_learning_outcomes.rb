module HasLearningOutcomes
  extend ActiveSupport::Concern

  included do
    has_many :learning_outcomes, as: :resource, dependent: :destroy
    accepts_nested_attributes_for :learning_outcomes, allow_destroy: true
  end
  
end
