# frozen_string_literal: true
module Decidim
  module Proposals
    # A form object to be used when public users want to report a proposal.
    class ProposalReportForm < Decidim::Form
      mimic :proposal_report

      attribute :reason, String

      validates :reason, inclusion: { in: ProposalReport::REASONS }
    end
  end
end
