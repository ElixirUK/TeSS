class DataProcessor
  
  def name
    return 'default_processor'
  end

  def content
    return 'Event'
  end
  
  def select
   return {}
  end
  
  def run(item)
  end
  
  # Clear all resources affected by this processor, so it can be run again
  def clear_run_processors
    query = Event if (self.content()=='Event')
    query = Material if (self.content()=='Material')
    if (query)
      query = query.where("'" + self.name() + "' = ANY (data_processor_list)")
    end

    query.find_each do |item|
      # For each match, remove this processor's name from its list
      item.data_processor_list.delete(self.name)
      item.save
    end
  end
end