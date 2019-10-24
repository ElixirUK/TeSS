module LearningStatementsHelper

  def print_learning_statement(statement, option = {})
    if statement.tool_name and !statement.tool_name.blank?
      tool_text = link_to("using #{statement.tool_name}", "https://bio.tools/#{statement.tool_id}", target: "_blank")
    end
    return "#{statement.verb} #{statement.noun} #{tool_text}".html_safe
  end

end
