module CuratorsHelper

  def print_curation_action(action)
    resource, action = action.split('.')
    if action
      action, topic = action.split('_')
      action += 'ed'
      return "#{topic} suggestions #{action=='rejected' ? action + " from " : action + ' to '}#{resource}s".humanize
    else
      return resource.humanize
    end
  end

  def activity_action(act)
    resource, action = act.split('.')
    if action
      action, topic = action.split('_')
    end
    return action
  end

  def activity_resource_type(act)
    resource, action = act.split('.')
    return resource
  end
end
