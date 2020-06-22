# frozen_string_literal: true

module Decidim
  module Proposals
    # A proposal can include a notes created by admins.
    class ProposalNote < ApplicationRecord
      include Decidim::Traceable
      include Decidim::Loggable
      include Decidim::TranslatableResource

      translatable_fields :body

      belongs_to :proposal, foreign_key: "decidim_proposal_id", class_name: "Decidim::Proposals::Proposal", counter_cache: true
      belongs_to :author, foreign_key: "decidim_author_id", class_name: "Decidim::User"

      default_scope { order(created_at: :asc) }

      def self.log_presenter_class_for(_log)
        Decidim::Proposals::AdminLog::ProposalNotePresenter
      end
    end
  end
end
