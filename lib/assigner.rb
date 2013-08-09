class Assigner
  attr_accessor :raw, :toggle_id, :issue_id, :comment, :activity

  def initialize(raw, special_case_mapper = SpecialCaseMapper.new)
    self.raw = self.comment = raw

    extract_toggle_id
    extract_issue_id
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

  def extract_issue_id
    id, text = self.comment.split(' ', 2)
    if id.to_i.to_s == id
      self.issue_id = id.to_i
      self.comment = text.to_s
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
    !issue_id.nil?
  end
end