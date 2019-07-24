$fairsharing_url = 'https://fairsharing.org/'

namespace :fairsharing do

  desc 'Adds links to FAIRsharing records as external resources of materials'
  task :create_links => [:environment] do

    # Parse data file manually imported from FAIRsharing
    datafile = "#{Rails.root}/config/data/tess_links.csv"
    begin
      lines = IO.readlines(datafile)
    rescue
      puts "Could not open datafile: #{datafile}"
      exit 0
    end

    # Add external resources, checking first for existence
    lines.each do |line|
      bid,bname,turl = line.split(/\|/)
      tslug = turl.chomp.split(/\//)[-1]
      m = Material.find_by_slug(tslug)
      if !m.nil?
        existing = m.external_resources.find_by_url($fairsharing_url + bid)
        if existing.nil?
          enew = ExternalResource.new(:title => bname, :url => $fairsharing_url + bid)
          enew.save
          m.external_resources << enew
          puts "Adding link for: #{bid}/#{tslug}"
        else
          puts "Already found resources for: #{bid}/#{tslug}"
        end
      end
    end
  end

end

namespace :fairsharing do
  desc 'Find mentions of FAIRSharing resources within resource descriptions'
  task :guess_links => [:environment] do
    fairsharing_records = open('https://fairsharing.org/content/record_names').read
    fair = JSON.parse(fairsharing_records)
    materials = Material.all
    count = 0
    total = 0
    File.open('config/data/tess-links.yml', 'w') do |file|

      materials.each do |material|
        fair.each do |record|
          desc = "#{material.short_description} #{material.long_description}"
          begin
            if desc.include?(record['name'])
              fairsharing_link = "#{$fairsharing_url}#{record['id']}"
              if material.external_resources and
                  material.external_resources.select{|x| x.url == fairsharing_link}.any?
                    puts "[LINKED ALREADY] FS:#{record['name']} may match TS:#{material.title} new match"
                    next
              else
                puts "FS:#{record['name']} may match TS:#{material.title} new match"
                count = count + 1
                fairsharing_description = ""
                resource_type = /bsg-([d|s|p])(\d*)/.match(record['id'])[1]
                case resource_type
                  when 'd'
                    lookup = "https://fairsharing.org/api/database/summary/#{record['id']}"
                  when 'p'
                    lookup = "https://fairsharing.org/api/policy/summary/#{record['id']}"
                  when 's'
                    lookup = "https://fairsharing.org/api/standard/summary/#{record['id']}"
                end
                fairsharing_data = JSON.parse(open(lookup,
                     "Api-Key" => "7f1af03ac7aec02b572656550f37d2f1e8f77b7b").read)
                fairsharing_description = fairsharing_data["data"]["description"]

                file.write("
#{count}:
    fairsharing_url: #{$fairsharing_url}#{record['id']}
    fairsharing_name: #{record['name']}
    fairsharing_description: >
          #{fairsharing_description}
    tess_url: https://tess.elixir-europe.org/materials/#{material.id}
    tess_name: #{material.title}
    tess_description: >
          #{material.short_description.truncate(200) unless material.short_description.nil?}
          #{material.long_description.truncate(200) unless material.long_description.nil?}
")
        #          material.external_resources << ExternalResource.new(url: $fairsharing_url + record['id'], title: record['name'])
        #          material.save!

                end
            end
                total += 1
          rescue => exception
            puts "Something went wrong #{exception}"
            next
          end
        end
        puts "#{count} / #{total}"
      end
    end
  end
end

