class SpecialCaseMapper
  def map!(assigner)
    s = assigner.comment.downcase
    meeting_strings = ['internal weekly meeting', 'weekly meeting', 
    'wöchentliches meeting', 'sitzung vorbereiten', 'internes meeting']
    
    if meeting_strings.any?{|m| s.start_with?(m.downcase)}
      assigner.issue_ids << 1339
      assigner.activity = "Meetings"
    elsif s.start_with?('internal entwicklung bills')
      assigner.issue_ids << 831
      assigner.activity = "Entwicklung"
    elsif s.start_with?('griffin review') || s.start_with?('griffin retro')
      assigner.issue_ids << 5268
      assigner.activity = "Meetings"
    elsif s.start_with?('griffin planning') || s.start_with?('griffin planing')
      assigner.issue_ids << 5281
      assigner.activity = "Meetings"
    end
  end
end
