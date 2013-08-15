class SpecialCaseMapper
  def map!(assigner)
    if assigner.comment.downcase.start_with?('internal Weekly Meeting')
      assigner.issue_id = 965
      assigner.activity = "Meetings"
    end
  end
end
