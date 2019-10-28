class VerbDictionary < Dictionary

  private

  def dictionary_filepath
    File.join(Rails.root, "config", "dictionaries", "verb.yml")
  end

end
