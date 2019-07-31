class MaterialPolicy < ScrapedResourcePolicy

  def add_learning_statements?
    @user.is_curator? || @user.is_admin?
  end
end