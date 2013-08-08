class Splitter
  attr_accessor :redmine_adapter, :assigner

  def initialize(redmine_adaper = RedmineAdapter.new)
    self.redmine_adapter = redmine_adapter
  end

  def split_time_entries
    redmine_adapter.time_entries.each do |t|
      Assigner.new(t.comment)
    end
  end
end
