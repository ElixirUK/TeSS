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
          query = query.where(latitude:queryParams[:latitude]) if queryParams.key?(:latitude)
          query = query.where(longitude:queryParams[:longitude]) if queryParams.key?(:longitude)
          query = query.where(postcode:queryParams[:postcode]) if queryParams.key?(:postcode)
          # query = query.where(online:queryParams[:online]) if queryParams.key?(:online)
          # query = query.where(online:queryParams[:online]) if queryParams.key?(:dateBefore)

          count=0
          query.find_each do |item|
            count+=1
            task.run(item)
            # mark item as processed
            item.data_processor_list.push(task.name())
            item.save
          end
          log_file.puts "#{count} events processed"
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
end