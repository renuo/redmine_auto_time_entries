class SpecialCaseMapper
  def map!(assigner)
    if assigner.comment.start_with?('Weekly Renuo Meeting')
      assigner.issue_id = 965
      assigner.activity = "Meetings"
    end
  end
end