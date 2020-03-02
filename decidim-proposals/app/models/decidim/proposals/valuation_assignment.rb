# frozen_string_literal: true

module Decidim
  module Proposals
    # A valuation assignment links a proposal and a Valuator user role.
    # Valuators will be users in charge of defining the monetary cost of a
    # proposal.
    class ValuationAssignment < ApplicationRecord
      include Decidim::Traceable
      include Decidim::Loggable

      belongs_to :proposal, foreign_key: "decidim_proposal_id", class_name: "Decidim::Proposals::Proposal"
      belongs_to :valuator_role, polymorphic: true

      def self.log_presenter_class_for(_log)
        Decidim::Proposals::AdminLog::ValuationAssignmentPresenter
      end

      def valuator
        valuator_role.user
      end
    end
  end
end
