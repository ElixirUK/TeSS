class EditSuggestion < ActiveRecord::Base
  belongs_to :suggestible, polymorphic: true

  include HasScientificTopics

  def accept_suggestion resource, topic
    resource.scientific_topics = resource.scientific_topics.push(topic)
    if resource.save!
      suggestions = drop_topic({uri: topic.uri})
      self.destroy if suggestions.nil? or suggestions.empty?
    end
  end

  def reject_suggestion topic
    suggestions = self.drop_topic({uri: topic.uri})
    self.destroy if suggestions.empty?
  end

  def self.create_suggestion resource, topic
    suggestion = resource.edit_suggestion
    if suggestion.nil?
      es = EditSuggestion.new(
                             suggestible: resource,
                             scientific_topics: [topic]
      )
      es.save!
    else
      suggestion.scientific_topics << topic
      suggestion.save!
    end
  end

  #Params: :uri => http://edamontology.org/3023
  #        :name => 'RNA-Seq'
  def drop_topic options={}
    if !options[:uri].nil?
      topics = self.scientific_topics
      topic_index = topics.index{|x| x.uri == options[:uri]}
      if topic_index
        topics.delete_at(topic_index)
        self.scientific_topics = topics
        self.save!
        return self.scientific_topics
      else
        return nil
      end
    end
  end

end
