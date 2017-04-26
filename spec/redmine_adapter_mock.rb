class RedmineAdapterMock
  #<TimeEntry id: 1815, project_id: 24, user_id: 1, issue_id: 916, hours: 0.2325, comments: "84561435: Intern - Sitzung - Nächste Sitzung vorber...", activity_id: 45, spent_on: "2013-07-30", tyear: 2013, tmonth: 7, tweek: 31, created_on: "2013-07-30 14:40:32", updated_on: "2013-07-30 14:40:32">
  TimeEntryMock = Struct.new(:issue_id, :spent_on, :comments, :activity_id, :hours, :id, :saved) do
    def save!
      self.saved = true
    end

    def saved?
      !!saved
    end
  end

  attr_accessor :time_entries, :activities_mapping

  def initialize
    self.activities_mapping = {}
  end

  def mock_time_entries time_entries
    self.time_entries = time_entries
  end

  def time_entries_to_assign
    time_entries
  end

  def id_for_activity_name name
    activities_mapping[name]
  end

  def duplicate_time_entry time_entry
    t = time_entry.dup
    time_entries << t
    t
  end

  def transaction
    yield
  end

  def set_default_time_entry_activity(_new_time_entry)
    # pass
  end
end
