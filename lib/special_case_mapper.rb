CommentTicketMapping = Struct.new('CommentTicketMapping', :start_with, :issue_id)

class SpecialCaseMapper
  def initialize
    @mapping = [
      CommentTicketMapping.new('internal weekly meeting', 1339),
      CommentTicketMapping.new('weekly meeting', 1339),
      CommentTicketMapping.new('internal meeting', 1339),
      CommentTicketMapping.new('griffin review', 4999),
      CommentTicketMapping.new('griffin retro', 4999),
      CommentTicketMapping.new('griffin planning', 4999),
      CommentTicketMapping.new('griffin planing', 4999),
      CommentTicketMapping.new('wg-bin-check', 5640),
      CommentTicketMapping.new('wg-hosting', 5516),
      CommentTicketMapping.new('wg-operations', 5516),
      CommentTicketMapping.new('operations', 5516),
      CommentTicketMapping.new('ops', 5516),
      CommentTicketMapping.new('office', 6634),
      CommentTicketMapping.new('hiring', 5510),
      CommentTicketMapping.new('employing', 5510)
      CommentTicketMapping.new('wg-education', 7426)
      CommentTicketMapping.new('education', 7426)
    ]
  end

  def map!(assigner)
    comment = assigner.comment.downcase
    match = @mapping.find { |mapping| comment.start_with?(mapping.start_with) }
    assigner.issue_ids << match.issue_id if match
  end
end
