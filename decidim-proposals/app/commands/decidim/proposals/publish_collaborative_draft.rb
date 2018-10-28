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
          @collaborative_draft.requesters.each do |requester_user|
            RejectAccessToCollaborativeDraft.call(@collaborative_draft, current_user, requester_user)
          end

          @new_proposal = publish_collaborative_draft
          broadcast(:invalid) unless @new_proposal
        end

        broadcast(:ok, @new_proposal)
      end

      attr_accessor :new_proposal

      private

      def publish_collaborative_draft
        Decidim.traceability.update!(
          @collaborative_draft,
          @current_user,
          state: "published",
          published_at: Time.current
        )
        create_proposal
      end

      def create_proposal
        proposal_form_params = ActionController::Parameters.new(
          proposal: @collaborative_draft.as_json
        )
        proposal_form_params[:proposal][:category_id] = @collaborative_draft.category.id if @collaborative_draft.category
        proposal_form_params[:proposal][:scope_id] = @collaborative_draft.scope.id if @collaborative_draft.scope
        proposal_form = Decidim::Proposals::ProposalForm.from_params(
          proposal_form_params
        ).with_context(
          current_user: @current_user,
          current_organization: @current_user.organization,
          current_component: @collaborative_draft.component,
          current_participatory_space: @collaborative_draft.participatory_space
        )

        result = CreateProposal.call(proposal_form, @current_user, @collaborative_draft.coauthorships)
        return publish_proposal(result[:ok]) if result[:ok]

        false
      end

      def publish_proposal(new_proposal)
        result = PublishProposal.call(new_proposal, @current_user)
        return link_collaborative_draft_and_proposal(result[:ok]) if result[:ok]

        false
      end

      def link_collaborative_draft_and_proposal(new_proposal)
        @collaborative_draft.link_resources(new_proposal, "created_from_collaborative_draft")
        new_proposal
      end
    end
  end
end
