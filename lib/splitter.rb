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

    redmine_adapter.transaction do
      time_entry.issue_id = assigner.issue_ids.first
      time_entry.comments = "#{assigner.toggle_id}: #{assigner.comment}"
      set_activity(activity_id, assigner, time_entry)
      time_entry.hours = time_entry.hours / assigner.issue_ids.count
      time_entry.spent_on = assigner.spent_on if assigner.spent_on
      time_entry.project_id = nil # will reassign the correct project from issue
      time_entry.save!
      logger.info("Reassigned: #{time_entry.id}: #{time_entry.inspect}")

      assigner.issue_ids.drop(1).each do |current_issue_id|
        new_time_entry = redmine_adapter.duplicate_time_entry(time_entry)
        new_time_entry.issue_id = current_issue_id
        redmine_adapter.set_default_time_entry_activity(new_time_entry)
        new_time_entry.save!
        logger.info("Created: #{new_time_entry.id}: #{new_time_entry.inspect}")
      end
    end

    logger.info("---")
  end

  def set_activity(activity_id, assigner, time_entry)
    if activity_id.nil?
      time_entry.comments += ": #{assigner.activity}" unless assigner.activity.nil?
    else
      time_entry.activity_id = activity_id
    end
  end

  def activity_id_for_name activity_name
    redmine_adapter.id_for_activity_name(activity_name)
  end
end
