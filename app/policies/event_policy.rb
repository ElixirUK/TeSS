class EventPolicy < ScrapedResourcePolicy

  def edit_report?
    manage?
  end

  def view_report?
    manage?
  end

  def add_learning_statements?
    @user.is_curator? || @user.is_admin?
  end
end
