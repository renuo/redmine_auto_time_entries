class SpecialCaseMapper
  def map!(assigner)
    s = assigner.comment.downcase
    if s.start_with?('internal weekly meeting') || s.start_with?('Weekly Meeting')
      assigner.issue_id = 1117
      assigner.activity = "Meetings"
    elsif s.start_with?('internal entwicklung bills')
      assigner.issue_id = 831
      assigner.activity = "Entwicklung"
    end
  end
end
