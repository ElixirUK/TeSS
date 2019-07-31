module HasLearningStatements
  extend ActiveSupport::Concern

  included do
    has_many :learning_outcomes, as: :resource, dependent: :destroy
    has_many :prerequisites, as: :resource, dependent: :destroy

    accepts_nested_attributes_for :learning_outcomes, allow_destroy: true
    accepts_nested_attributes_for :prerequisites, allow_destroy: true

    before_validation :remove_duplicate_learning_outcomes
    before_validation :remove_duplicate_prerequisites
  end

  def remove_duplicate_learning_outcomes
    # New resources have a `nil` created_at, doing this puts them at the end of the array.
    # Sorting them this way means that if there are duplicates, the oldest resource is preserved.
    resources = learning_outcomes.to_a.sort_by { |x| x.created_at || 1.year.from_now }
    (resources - resources.uniq { |r| [r.noun, r.verb] }).each(&:mark_for_destruction)
  end


  def remove_duplicate_prerequisites
    # New resources have a `nil` created_at, doing this puts them at the end of the array.
    # Sorting them this way means that if there are duplicates, the oldest resource is preserved.
    resources = prerequisites.to_a.sort_by { |x| x.created_at || 1.year.from_now }
    (resources - resources.uniq { |r| [r.noun, r.verb] }).each(&:mark_for_destruction)
  end

end
