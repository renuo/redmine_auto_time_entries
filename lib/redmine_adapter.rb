class RedmineAdapter
  AUTO_TIME_ENTRIES_TICKET = 916

  def time_entries_to_assign
    TimeEntry.where(issue_id: RedmineAdapter::AUTO_TIME_ENTRIES_TICKET)
  end

  def id_for_activity_name name
    Activity.where(name: name).first
  end
end