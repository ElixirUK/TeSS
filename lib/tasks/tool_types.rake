namespace :biotools do

  desc 'Adds Tool Type from BioTools to ExternalResource records'
  task :add_types => [:environment] do

    ExternalResource.all.each do |resource|
      if resource.is_tool?
        name = resource.url.split(/\//)[-1]
        response = HTTParty.get("https://bio.tools/api/t/#{name}/?format=json")
        begin
          if response['toolType']
            type = response['toolType'].join(', ')
            puts "Adding tool_type '#{type}' to '#{name}'."
            resource.tool_type = type
            puts resource.tool_type
            resource.save
          end
        rescue Exception => e
          puts "Failed to query resource '#{name}': #{e.inspect}"
        end
      end
    end

  end
end