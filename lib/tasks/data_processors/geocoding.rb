require 'redis'

class Geocoding < DataProcessor
  
  # Returns the name of the class
  def name
    return 'Geocoding'
  end

  # Type of content that this data processor will query from
  def content
    return 'Event'
    # return 'Material'
  end
  
  # Criteria to query the data to process, in json format
  def select
    return { latitude: nil, longitude: nil}
  end
  
  # Function to run on EACH item matching the criteria specified in select()
  def run(item)
    if (item.nominatim_count<Event::NOMINATIM_MAX_ATTEMPTS)
      # Submit a worker for each matching event, one per minute.
      item.enqueue_geocoding_worker()
    end
  end

end