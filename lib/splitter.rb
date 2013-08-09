require 'logger'

class Splitter
  attr_accessor :redmine_adapter, :logger

  def initialize(redmine_adapter = RedmineAdapter.new, logger = Logger.new(STDOUT))
    self.redmine_adapter = redmine_adapter
    self.logger = logger
  end

  def split_time_entries
    redmine_adapter.time_entries_to_assign.each do |t|
      a = Assigner.new(t.comments)
      reassign_time_entry(t, a) if a.valid? && a.assignable?
    end
  end

  def reassign_time_entry(time_entry, assigner)
    logger.info("Reassigning time entry #{time_entry.id}: #{time_entry.inspect} with #{assigner.inspect}")

    activity_id = activity_id_for_name(assigner.activity)
    logger.info("No activity found for #{time_entry.id}") if activity_id.nil?

    time_entry.issue_id = assigner.issue_id
    time_entry.comments = "#{assigner.toggle_id}: #{assigner.comment}"
    if activity_id.nil?
      time_entry.comments += ": #{assigner.activity}" unless assigner.activity.nil?
    else
      time_entry.activity_id = activity_id
    end
    time_entry.save!

    logger.info("Done #{time_entry.id}: #{time_entry.inspect}")
  end

  def activity_id_for_name activity_name
     redmine_adapter.id_for_activity_name(activity_name)
  end
end
