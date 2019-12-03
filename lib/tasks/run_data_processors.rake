# To add a task, create an object in the data_processors folder, and add its name to a new line in data_processor_list.txt

namespace :tess do
 
  desc 'Run data processors'
  task run_data_processors: :environment do
    Dir['lib/tasks/data_processors/*.rb'].each do |file|
      puts(file)
      load file
    end

    File.readlines(Dir['lib/tasks/data_processors/*.txt'].first).each do |taskName|
      puts taskName
      
      begin
        # Instantiate the task from its name in the txt
        task = Object.const_get(taskName.chomp("\n")).new()
        puts("content: #{task.content()}, selector '#{task.select()}'")

        # Select the content to act on
        query = Event if (task.content()=='Event')
        query = Material if (task.content()=='Material')

        if (query)
          # Build the query
          queryParams = task.select()

          # New parameters will need to be added depending on the data_processors needs
          p "latitude" if queryParams[:latitude]
          p queryParams
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
          end
          puts "#{query.count} events processed"
        else
          # process incorrect content in data_processors
          p "Incorrect value returned by content() function"
        end
      rescue => exception
        puts (exception)
        puts ("#{taskName.chomp("\n")} class cannot be instantiated")
        puts ("Make sure there is a class (.rb) defining it in the data_processors folder")
      end
    end
  end
end