class SpecialCaseMapper
  def map!(assigner)
    s = assigner.comment.downcase
    if s.start_with?('internal weekly meeting') || s.start_with?('weekly meeting') || s.start_with?('wöchentliches meeting') || s.start_with?('sitzung vorbereiten') || s.start_with?('internes meeting')
      assigner.issue_ids << 1339
      assigner.activity = "Meetings"
    elsif s.start_with?('internal entwicklung bills')
      assigner.issue_ids << 831
      assigner.activity = "Entwicklung"
    end
  end
end
