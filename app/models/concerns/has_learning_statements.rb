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


  # Any courses that fulfil more than one prerequisites?
  #
  # Output format:
  # {
  #   resource_1 => [prerequisite_1, prerequisite_2, prerequisite_3]
  #   resource_2 => [prerequisite_1, prerequiste_4]
  # }
  #
  # recommended_courses[resource] << [prerequisites]
  #
  def recommended_courses
    prereq_resources = {}
    recommended = {}
    # Collect all the materials for each prerequisite of this resource
    prerequisites.each do |prerequisite|
      matching_resources = prerequisite.matching_learning_outcomes
      unless matching_resources.blank?
        prereq_resources[prerequisite] = prerequisite.matching_learning_outcomes
      end
    end

    # Flip the hash to set the keys as materials and values as prerequisites
    prereq_resources.each do |prerequisite, resources|
      resources.each do | resource |
        if recommended[resource]
          recommended[resource] << prerequisite
        else
          recommended[resource] = [prerequisite]
        end
      end
    end
    recommended
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

  def learning_tree
    tree = get_tree(self)
    print_tree(tree)
  end

  private

  # Recursively get the training pre-requisite tree for a target course
  def get_tree(target_resource, seen = [])
    seen << target_resource
    required_trainings = []

    # Get an array of all the training which satisfy this courses pre-requisites
    # TODO: Group these by which pre-req they satisfy
    pre_reqs = target_resource.prerequisites
    pre_reqs.each do |pre_req|
      pre_req.matching_learning_outcomes.each do |resource|
        unless seen.include?(resource)
          required_trainings << {
              :resource => resource,
              :pre_req => pre_req
          }
        end
      end
    end

    branch = []
    if required_trainings.count.positive?
      # For each required training resource that hasn't already come up
      #   Call this function again to get its required training
      required_trainings.each do |required_training|
        resource = required_training[:resource]
        seen << resource
        sub_tree = get_tree(resource, seen)
        branch << if sub_tree.blank?
                       required_training
                     else
                       { required_training => sub_tree }
                     end
        seen.pop
      end
    end
    branch
  end

  def node_text(resource, pre_req)
    if pre_req.nil?
      "#{resource.title}\n<br/>"
    else
      "#{resource.title} [#{pre_req.verb} #{pre_req.noun}]<br/>"
    end
  end

  def print_tree(subtree, string=[], spaces=4, level=1)
    if subtree.is_a? Hash
      if subtree.key?(:resource) #leaf node
        string << "#{'&nbsp;'*spaces*level} #{node_text(subtree[:resource], subtree[:pre_req])}"
      elsif subtree.keys.is_a? Array and subtree.keys.first.key?(:resource) #Connected node
        string << "#{' '*spaces*level}#{node_text(subtree.keys.first[:resource], subtree.keys.first[:pre_req])}"
        print_tree(subtree.values,string,spaces,level+1)
      end
    elsif subtree.is_a? Array
      subtree.each do |item|
        print_tree(item,string,spaces,level+1)
      end
    else
      string << "#{' '*spaces*level}#{subtree.title}"
    end
    string.join("")
  end

end
