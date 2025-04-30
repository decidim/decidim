# frozen_string_literal: true

module Decidim
  module Proposals
    class CollaborativeDraft < Proposals::ApplicationRecord
      include Decidim::Resourceable
      include Decidim::Coauthorable
      include Decidim::HasComponent
      include Decidim::ScopableResource
      include Decidim::HasReference
      include Decidim::HasCategory
      include Decidim::Reportable
      include Decidim::HasAttachments
      include Decidim::Followable
      include Decidim::Proposals::CommentableCollaborativeDraft
      include Decidim::Traceable
      include Decidim::Loggable
      include Decidim::Randomable
      include Decidim::FilterableResource

      has_many :collaborator_requests,
               class_name: "Decidim::Proposals::CollaborativeDraftCollaboratorRequest",
               foreign_key: :decidim_proposals_collaborative_draft_id,
               dependent: :destroy

      has_many :requesters,
               through: :collaborator_requests,
               source: :user,
               class_name: "Decidim::User",
               foreign_key: :decidim_user_id

      geocoded_by :address

      STATES = { open: 0, published: 10, withdrawn: -1 }.freeze

      enum state: STATES, _default: "open"
      scope :except_withdrawn, -> { not_withdrawn.or(where(state: nil)) }

      scope_search_multi :with_any_state, [:open, :published, :withdrawn]

      # Checks whether the user can edit the given proposal.
      #
      # user - the user to check for authorship
      def editable_by?(user)
        authored_by?(user)
      end

      def presenter
        Decidim::Proposals::CollaborativeDraftPresenter.new(self)
      end

      # Public: Overrides the `reported_attributes` Reportable concern method.
      def reported_attributes
        [:body]
      end

      # Public: Overrides the `reported_searchable_content_extras` Reportable concern method.
      def reported_searchable_content_extras
        [authors.map(&:name).join("\n")]
      end

      # Create the :search_text ransacker alias for searching from both :title or :body.
      ransacker_text_multi :search_text, [:title, :body]

      def self.ransackable_scopes(_auth_object = nil)
        [:with_any_state, :related_to, :with_any_scope, :with_any_category]
      end
    end
  end
end
