class RedmineAdapter
  AUTO_TIME_ENTRIES_TICKET = 916

  def time_entries_to_assign
    TimeEntry.where(issue_id: RedmineAdapter::AUTO_TIME_ENTRIES_TICKET)
  end

  def id_for_activity_name name
    if @mapping.nil?
      @mapping = {}
      TimeEntryActivity.where(project_id: nil).each { |t| @mapping[t.name] = t.id }
    end
    @mapping[name]
  end
end
