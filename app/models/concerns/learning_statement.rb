module LearningStatement
  extend ActiveSupport::Concern

  included do
    belongs_to :resource, polymorphic: true
    validates :verb, controlled_vocabulary: { dictionary: VerbDictionary.instance }
    validates :noun, controlled_vocabulary: { dictionary: NounDictionary.instance }
  end

  def equals?(other)
    verb == other.verb && noun == other.noun
  end

  def noun_text
    term_val = ontology.lookup(self.noun)
    if term_val.nil?
      return ''
    else
      return term_val.label
    end
  end

  def ontology
    EDAM::Ontology.instance
  end


end