# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic when a user publishes a collaborative_draft.
    class PublishCollaborativeDraft < Decidim::Command
      # Public: Initializes the command.
      #
      # collaborative_draft - The collaborative_draft to publish.
      # current_user - The current user.
      # proposal_form - the form object of the new proposal
      def initialize(collaborative_draft, current_user)
        @collaborative_draft = collaborative_draft
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid and the collaborative_draft is published.
      # - :invalid if the collaborative_draft's author is not the current user.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless @collaborative_draft.open?
        return broadcast(:invalid) unless @collaborative_draft.authored_by? @current_user

        transaction do
          reject_access_to_collaborative_draft
          publish_collaborative_draft
          create_proposal!
          link_collaborative_draft_and_proposal
        end

        broadcast(:ok, @new_proposal)
      end

      attr_accessor :new_proposal

      private

      def reject_access_to_collaborative_draft
        @collaborative_draft.requesters.each do |requester_user|
          RejectAccessToCollaborativeDraft.call(@collaborative_draft, current_user, requester_user)
        end
      end

      def publish_collaborative_draft
        Decidim.traceability.update!(
          @collaborative_draft,
          @current_user,
          { state: "published", published_at: Time.current },
          visibility: "public-only"
        )
      end

      def proposal_attributes
        fields = {}

        parsed_title = @collaborative_draft.title
        parsed_body = @collaborative_draft.body

        fields[:title] = { I18n.locale => parsed_title }
        fields[:body] = { I18n.locale => parsed_body }
        fields[:component] = @collaborative_draft.component
        fields[:address] = @collaborative_draft.address
        fields[:published_at] = Time.current

        fields
      end

      def create_proposal!
        @new_proposal = Decidim.traceability.perform_action!(
          :create,
          Decidim::Proposals::Proposal,
          @current_user,
          visibility: "public-only"
        ) do
          new_proposal = Proposal.new(proposal_attributes)
          new_proposal.coauthorships = @collaborative_draft.coauthorships
          new_proposal.taxonomies = @collaborative_draft.taxonomies
          new_proposal.attachments = @collaborative_draft.attachments
          new_proposal.save!
          new_proposal
        end
      end

      def link_collaborative_draft_and_proposal
        @collaborative_draft.link_resources(@new_proposal, "created_from_collaborative_draft")
      end
    end
  end
end
