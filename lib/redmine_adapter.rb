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

  def duplicate_time_entry time_entry
    time_entry.dup
  end

  def transaction
    TimeEntry.transaction do
      yield
    end
  end

  def set_default_time_entry_activity(new_time_entry)
    new_time_entry.activity = TimeEntryActivity.where(project_id: new_time_entry.issue.project_id).first unless new_time_entry.valid?
    new_time_entry.activity = TimeEntryActivity.default unless new_time_entry.valid?
    new_time_entry.activity = TimeEntryActivity.where(name: "Entwicklung").first unless new_time_entry.valid?
    new_time_entry.activity = TimeEntryActivity.where(parent_id: nil, project_id: nil).first unless new_time_entry.valid?
  end
end
