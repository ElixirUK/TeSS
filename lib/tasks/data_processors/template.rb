
class Template < DataProcessor

  ## Possible constants to be used in the data processor
  CONSTANT_1 = 'example text'
  CONSTANT_2 = false
  
  # Returns the name of the class
  def name
    return 'Template'
  end

  # Type of content that this data processor will query from
  def content
    # return 'Event'
    # return 'Material'
  end
  
  # Criteria to query the data to process, in json format
  def select
    return { latitude: nil, longitude: nil, online: false, postcode:nil}
  end
  
  # Function to run on EACH item matching the criteria specified in select()
  def run(item)
    puts item.description
    extraFunction(item.title)
  end
  
  # Optionally, instead of using 'run', you can use this function to run the code on the entire list of results
  def runBulk(query)
    return false
  end

  # You can Instantiate and use additional functions as they won't affect the rake task
  def extraFunction(text)
    puts test
  end

end