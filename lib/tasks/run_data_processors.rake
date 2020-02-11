# To add a task, create an object in the data_processors folder, and add its name to a new line in data_processor_list.txt
log = 'log/data_processors.log' # The log file for this script, just mentions which scrapers are run.

namespace :tess do
 
  desc 'Run data processors'
  task run_data_processors: :environment do
    log_file = File.open(log, 'w')

    Dir['lib/tasks/data_processors/*.rb'].each do |file|
      log_file.puts "Loading file: #{file}"
      load file
    end

    File.readlines(Dir['lib/tasks/data_processors/*.txt'].first).each do |taskName|
      log_file.puts "Running #{taskName}"

      begin
        # Instantiate the task from its name in the txt
        task = Object.const_get(taskName.chomp("\n")).new()

        # Basic validation of task attributes
        raise "name is not correctly defined" if !task.name().is_a?(String)
        raise "content is not correctly defined" if !task.content().is_a?(String)
        raise "Select is not correctly defined" if !task.select().is_a?(Hash)

        # Select the content to act on
        query = Event if (task.content()=='Event')
        query = Material if (task.content()=='Material')

        if (query)
          # Build the query

          # Start discarding resources already run by this processor
          query = query.where("'"+ task.name() + "' <> ALL (data_processor_list)")

          # Break down each of the params given in the selection
          queryParams = task.select()
          # New parameters will need to be added depending on the data_processors needs
          # TODO: we could connect this to a sunspot solr (search controller), to add more flexibility to the queries
          query = constructQuery(query, queryParams)

          # query = query.where(online:queryParams[:online]) if queryParams.key?(:dateBefore)

          count=0
          query.find_each do |item|
            count+=1
            task.run(item)
            # mark item as processed
            item.data_processor_list.push(task.name())
            item.save
          end
          log_file.puts "#{count} items processed"
        else
          # process incorrect content in data_processors
          log_file.puts "Incorrect value returned by content() function"
        end
      rescue => e
        log_file.puts e.message
        log_file.puts e.backtrace.join("\n")
      end
    end
  end

  def constructQuery(query, queryParams)
    begin
      query = query.where(online:queryParams[:online]) if queryParams.key?(:online)
      query = query.where(description:queryParams[:online]) if queryParams.key?(:description)
      query = query.where(title:queryParams[:title]) if queryParams.key?(:title)
      query = query.where(Genomes:queryParams[:Genomes]) if queryParams.key?(:Genomes)
      query = query.where(subtitle:queryParams[:subtitle]) if queryParams.key?(:subtitle)
      query = query.where(url:queryParams[:url]) if queryParams.key?(:url)
      query = query.where(organizer:queryParams[:organizer]) if queryParams.key?(:organizer)
      query = query.where(description:queryParams[:description]) if queryParams.key?(:description)
      query = query.where(Duration:queryParams[:Duration]) if queryParams.key?(:Duration)
      query = query.where(start:queryParams[:start]) if queryParams.key?(:start)
      query = query.where(end:queryParams[:end]) if queryParams.key?(:end)
      query = query.where(sponsors:queryParams[:sponsors]) if queryParams.key?(:sponsors)
      query = query.where(venue:queryParams[:venue]) if queryParams.key?(:venue)
      query = query.where(city:queryParams[:city]) if queryParams.key?(:city)
      query = query.where(county:queryParams[:county]) if queryParams.key?(:county)
      query = query.where(country:queryParams[:country]) if queryParams.key?(:country)
      query = query.where(postcode:queryParams[:postcode]) if queryParams.key?(:postcode)
      query = query.where(latitude:queryParams[:latitude]) if queryParams.key?(:latitude)
      query = query.where(longitude:queryParams[:longitude]) if queryParams.key?(:longitude)
      query = query.where(created_at:queryParams[:created_at]) if queryParams.key?(:created_at)
      query = query.where(updated_at:queryParams[:updated_at]) if queryParams.key?(:updated_at)
      query = query.where(source:queryParams[:source]) if queryParams.key?(:source)
      query = query.where(slug:queryParams[:slug]) if queryParams.key?(:slug)
      query = query.where(content_provider_id:queryParams[:content_provider_id]) if queryParams.key?(:content_provider_id)
      query = query.where(user_id:queryParams[:user_id]) if queryParams.key?(:user_id)
      query = query.where(online:queryParams[:online]) if queryParams.key?(:online)
      query = query.where(cost:queryParams[:cost]) if queryParams.key?(:cost)
      query = query.where(for_profit:queryParams[:for_profit]) if queryParams.key?(:for_profit)
      query = query.where(last_scraped:queryParams[:last_scraped]) if queryParams.key?(:last_scraped)
      query = query.where(scraper_record:queryParams[:scraper_record]) if queryParams.key?(:scraper_record)
      query = query.where(keywords:queryParams[:keywords]) if queryParams.key?(:keywords)
      query = query.where(event_types:queryParams[:event_types]) if queryParams.key?(:event_types)
      query = query.where(target_audience:queryParams[:target_audience]) if queryParams.key?(:target_audience)
      query = query.where(capacity:queryParams[:capacity]) if queryParams.key?(:capacity)
      query = query.where(eligibility:queryParams[:eligibility]) if queryParams.key?(:eligibility)
      query = query.where(contact:queryParams[:contact]) if queryParams.key?(:contact)
      query = query.where(host_institutions:queryParams[:host_institutions]) if queryParams.key?(:host_institutions)
      query = query.where(timezone:queryParams[:timezone]) if queryParams.key?(:timezone)
      query = query.where(funding:queryParams[:funding]) if queryParams.key?(:funding)
      query = query.where(attendee_count:queryParams[:attendee_count]) if queryParams.key?(:attendee_count)
      query = query.where(applicant_count:queryParams[:applicant_count]) if queryParams.key?(:applicant_count)
      query = query.where(trainer_count:queryParams[:trainer_count]) if queryParams.key?(:trainer_count)
      query = query.where(feedback:queryParams[:feedback]) if queryParams.key?(:feedback)
      query = query.where(notes:queryParams[:notes]) if queryParams.key?(:notes)
      return query
    end
  end
end