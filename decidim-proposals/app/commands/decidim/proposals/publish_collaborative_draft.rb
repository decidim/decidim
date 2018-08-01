# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic when a user publishes a collaborative_draft.
    class PublishCollaborativeDraft < Rectify::Command
      # Public: Initializes the command.
      #
      # collaborative_draft - The collaborative_draft to publish.
      # current_user - The current user.
      # proposal_form - the form object of the new proposal
      def initialize(collaborative_draft, current_user, proposal_form)
        @collaborative_draft = collaborative_draft
        @current_user = current_user
        @proposal_form = proposal_form
        @new_proposal = nil
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid and the collaborative_draft is published.
      # - :invalid if the collaborative_draft's author is not the current user.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if @collaborative_draft.published?
        return broadcast(:invalid) if @collaborative_draft.withdrawn?
        return broadcast(:invalid) unless @collaborative_draft.authors.exists? @current_user.id

        transaction do
          @collaborative_draft.requesters.each do |requester_user|
            RejectAccessToCollaborativeDraft.call(@collaborative_draft, current_user, requester_user)
          end

          publish_collaborative_draft
        end

        broadcast(:ok, @new_proposal)
      end

      attr_accessor :new_proposal

      private

      def publish_collaborative_draft
        Decidim.traceability.update!(
          @collaborative_draft,
          @current_user,
          state: "published"
        )
        create_proposal
      end

      def create_proposal
        CreateProposal.call(@proposal_form, @current_user, @collaborative_draft.coauthorships) do
          on(:ok) do |new_proposal|
            publish_proposal new_proposal
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("proposals.create.error", scope: "decidim")
            return broadcast(:invalid)
          end
        end
      end

      def publish_proposal(new_proposal)
        @new_proposal = new_proposal

        PublishProposal.call(@new_proposal, @current_user) do
          on(:ok) do
            link_collaborative_draft_and_proposal
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("proposals.publish.error", scope: "decidim")
            return broadcast(:invalid)
          end
        end
      end

      def link_collaborative_draft_and_proposal
        @collaborative_draft.link_resources(@new_proposal, "created_from_collaborative_draft")
      end
    end
  end
end
