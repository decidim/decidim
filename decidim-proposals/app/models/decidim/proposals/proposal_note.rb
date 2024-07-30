# frozen_string_literal: true

module Decidim
  module Proposals
    # A proposal can include a notes created by admins.
    class ProposalNote < ApplicationRecord
      include Decidim::Traceable
      include Decidim::Loggable

      belongs_to :proposal, foreign_key: "decidim_proposal_id", class_name: "Decidim::Proposals::Proposal", counter_cache: true
      belongs_to :author, foreign_key: "decidim_author_id", class_name: "Decidim::User"
      has_many :replies, foreign_key: "parent_id", class_name: "Decidim::Proposals::ProposalNote", inverse_of: :parent, dependent: :destroy
      belongs_to :parent, class_name: "Decidim::Proposals::ProposalNote", inverse_of: :replies, optional: true

      scope :not_reply, -> { where(parent_id: nil) }
      default_scope { order(created_at: :asc) }

      def self.log_presenter_class_for(_log)
        Decidim::Proposals::AdminLog::ProposalNotePresenter
      end

      def reply?
        parent.present?
      end

      def formatted_body
        Decidim::ContentProcessor.render_without_format(body)
      end
    end
  end
end
