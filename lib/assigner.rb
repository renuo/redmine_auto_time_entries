class Assigner
  attr_accessor :raw, :toggle_id, :issue_ids, :comment, :activity, :spent_on

  def initialize(raw)
    self.raw = self.comment = raw
    self.issue_ids = []

    extract_toggle_id
    extract_issue_ids
    extract_activity
    extract_spent_on
  end

  def extract_toggle_id
    return unless raw.include?(':')
    self.toggle_id, self.comment = self.raw.split(':', 2).collect(&:strip)
    self.toggle_id = toggle_id.to_i unless toggle_id.nil?
  end

  def try_extract_id
    try_id_comment_split(comment) || try_hash_id_comment_split(comment)
  end

  def try_id_comment_split(comment)
    id, comment = comment.split(' ', 2)
    return false if id.to_i.to_s != id

    self.issue_ids << id.to_i
    self.comment = comment.to_s
  end

  def try_hash_id_comment_split(comment)
    _tracker_name, potential_hash_id_comment = comment.split(' ', 2)

    return false if potential_hash_id_comment.nil? || !potential_hash_id_comment.start_with?('#')

    potential_id_and_comment = potential_hash_id_comment[1..-1]
    try_id_comment_split(potential_id_and_comment)
  end

  def extract_issue_ids
    if self.comment.start_with?('d ')
      self.comment.slice!(0..1)
      self.comment.strip!
      while try_extract_id
      end
    else
      try_extract_id
    end
  end

  def extract_activity
    return unless self.comment.include?(':')

    # Splits the last part after : and assigns it to activity
    self.comment, self.activity = self.comment.reverse.split(':', 2).collect(&:strip).collect(&:reverse).reverse
  end

  def extract_spent_on
    date_regex = /(\d{4})-(\d{2})-(\d{2})T/
    year, month, day = comment.scan(date_regex).last
    self.spent_on = Date.new(year.to_i, month.to_i, day.to_i) if year
  end

  def valid?
    !toggle_id.nil?
  end

  def assignable?
    !issue_ids.empty?
  end
end
