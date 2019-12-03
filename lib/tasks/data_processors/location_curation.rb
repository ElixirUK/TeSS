
class LocationCuration

  GB_postcode_Official_regex = /([Gg][Ii][Rr] 0[Aa]{2})|((([A-Za-z][0-9]{1,2})|(([A-Za-z][A-Ha-hJ-Yj-y][0-9]{1,2})|(([A-Za-z][0-9][A-Za-z])|([A-Za-z][A-Ha-hJ-Yj-y][0-9][A-Za-z]?))))\s?[0-9][A-Za-z]{2})\b/i
  # There is a space in front, so just numbers from a URL would not get accepted.
  EU_postcode_regex = /\s\d{5}\b/i
  NL_postcode_regex = /\d{4}\\s{0,1}[A-Za-z]{2}\b/i

  ONLINE_regex = /webinar|online/i

  def content
    return 'Event'
  end
  
  def select
    return { latitude: nil, longitude: nil, online: false, postcode:nil}
  end
  
  def run(item)
    
    if (item.curationList.get('LocationCuration')) return
    # Look for possible locations on the text
    postCode = extractPostCode(item.description)
    if postCode
      p "--------------------------"
      p item.slug
      p item.postcode
      p postCode
      
      # Update given item
      item.postcode = postCode
      item.curationList.push = {'LocationCuration':false}
      # item.save # do not save!! the curator will do that

      # Create and link a curation task
      curationTask = CurationTask.new
      curationTask.key = 'locate'
      curationTask.resource = item
      curationTask.message = 'New location provided, confirm'
      curationTask.updateFields = {postcode:postCode}
      curationTask.resource = item
      curationTask.save
      # curationTask = CurationTask.new(resource=item)
      # # Create location curation task, using the params for the creation
      # CurationTask.new(curation_task_params)
    end

    # Check if the event is online
    if (isOnline("#{item.title} #{item.subtitle} #{item.description}"))
      p "--------------------------"
      p "ONLINE"
      p item.slug

      item.online = true
      item.save

      curationTask = CurationTask.new
      curationTask.key = 'delete'
      # Example of SPAM event, marked to be deleted, it requires a new curation_task view
      # curationTask.key = 'delete'
      # curationTask.message = 'Is this SPAM?'
      # curationTask.updateFields = {}
      curationTask.message = 'The field says online. Check that the event is not online'
      curationTask.updateFields = {online:true, latitude:nil, longitude:nil}
      curationTask.resource = item
      curationTask.save
    end
  end

  def extractPostCode(text)
    begin
      if((tempRes = text.scan(GB_postcode_Official_regex)).length()>0)  
      elsif (tempRes = text.scan(EU_postcode_regex)).length()>0
      elsif (tempRes = text.scan(NL_postcode_regex)).length()>0
      else return nil
      end

      tempRes = tempRes[0]# regex results are returned in the first array position
        if tempRes.kind_of?(Array)
          # if there is more than one result, they are returned in a nested array, pick the longest
          return tempRes.compact.max_by(&:length).strip
        else
          return tempRes.strip
        end
    rescue => exception
      return nil
    end
  end

  def isOnline(text)
    begin
      if(text.scan(ONLINE_regex).length()>0)
        return true
      end
      return false
    rescue => exception
      return nil
    end
  end

end