class SpecialCaseMapper
  def map!(time_entry)
    if time_entry.comment.start_with?('Weekly Renuo Meeting')
      time_entry.issue_id = 965
      time_entry.activity_id = 33
    end
  end
end