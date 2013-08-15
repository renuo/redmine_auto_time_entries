class Assigner
  attr_accessor :raw, :toggle_id, :issue_ids, :comment, :activity

  def initialize(raw, special_case_mapper = SpecialCaseMapper.new)
    self.raw = self.comment = raw
    self.issue_ids = []

    extract_toggle_id
    extract_issue_ids
    extract_activity

    check_special_case(special_case_mapper)
  end

  def check_special_case(mapper)
    return unless valid?
    return if assignable?

    mapper.map!(self)
  end

  def extract_toggle_id
    return unless raw.include?(':')
    self.toggle_id, self.comment = self.raw.split(':', 2).collect(&:strip)
    self.toggle_id = toggle_id.to_i unless toggle_id.nil?
  end

  def try_extract_id
    id, text = self.comment.split(' ', 2)
    success = id.to_i.to_s == id
    if success
      self.issue_ids << id.to_i
      self.comment = text.to_s
    end
    return success
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

  def valid?
    !toggle_id.nil?
  end

  def assignable?
    !issue_ids.empty?
  end
end