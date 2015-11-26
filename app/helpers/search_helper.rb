module SearchHelper
	def filter_link name, value
		new_parameter = {name => value}
		parameters = request.parameters.clone
		#if there's already a filter of the same facet type, create/add to an array
		if parameters.include?(name) 
			if !parameters[name].include?(value)
		    	new_parameter = {name => [parameters.delete(name), value].flatten}
		    else new_parameter = {}
		    end
		end
		#remove the page option if it exists
		parameters.delete('page')
		return link_to value, parameters.merge(new_parameter)
	end

	def remove_filter_link name, value
	  parameters = request.parameters.clone
	  
	  #delete a filter from an array or delete the whole facet if it is the only one
	  if parameters.include?(name) 
	  	if parameters[name].is_a?(Array)
	  		parameters[name].delete(value)
	  	else parameters.delete(name) 
	  	end
	  end
	  #remove the page option if it exists
      parameters.delete('page')
	  return link_to "x #{value}", parameters 
	end
end
