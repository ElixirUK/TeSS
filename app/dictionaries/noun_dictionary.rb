class NounDictionary < Dictionary

  private

  def dictionary_filepath
    File.join(Rails.root, "config", "dictionaries", "noun.yml")
  end

end
