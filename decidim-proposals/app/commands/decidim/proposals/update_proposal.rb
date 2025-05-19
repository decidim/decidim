# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic when a user updates a proposal.
    class UpdateProposal < Decidim::Command
      include ::Decidim::MultipleAttachmentsMethods

      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # current_user - The current user.
      # proposal - the proposal to update.
      def initialize(form, current_user, proposal)
        @form = form
        @current_user = current_user
        @proposal = proposal
        @attached_to = proposal
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the proposal.
      # - :invalid if the form was not valid and we could not proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if invalid?

        if process_attachments?
          build_attachments
          return broadcast(:invalid) if attachments_invalid?
        end

        with_events(with_transaction: true) do
          if @proposal.draft?
            update_draft
          else
            update_proposal
          end

          document_cleanup!(include_all_attachments: true)

          create_attachments(first_weight: first_attachment_weight) if process_attachments?
        end

        broadcast(:ok, proposal)
      end

      private

      attr_reader :form, :proposal, :current_user, :attachment

      def event_arguments
        {
          resource: proposal,
          extra: {
            event_author: form.current_user,
            locale:
          }
        }
      end

      def invalid?
        form.invalid? || !proposal.editable_by?(current_user) || proposal_limit_reached?
      end

      # Prevent PaperTrail from creating an additional version
      # in the proposal multi-step creation process (step 3: complete)
      #
      # A first version will be created in step 4: publish
      # for diff rendering in the proposal control version
      def update_draft
        PaperTrail.request(enabled: false) do
          @proposal.update(attributes)
          @proposal.coauthorships.clear
          @proposal.add_coauthor(current_user)
        end
      end

      def update_proposal
        @proposal = Decidim.traceability.update!(
          @proposal,
          current_user,
          attributes,
          visibility: "public-only"
        )
        @proposal.coauthorships.clear
        @proposal.add_coauthor(current_user)
      end

      def attributes
        {
          title: {
            I18n.locale => form.title
          },
          body: {
            I18n.locale => form.body
          },
          taxonomizations: form.taxonomizations,
          address: form.address,
          latitude: form.latitude,
          longitude: form.longitude
        }
      end

      def proposal_limit_reached?
        proposal_limit = form.current_component.settings.proposal_limit

        return false if proposal_limit.zero?

        current_user_proposals.count >= proposal_limit
      end

      def first_attachment_weight
        return 1 if proposal.photos.count.zero?

        proposal.photos.count
      end

      def organization
        @organization ||= current_user.organization
      end

      def current_user_proposals
        Proposal.from_author(current_user).where(component: form.current_component).published.where.not(id: proposal.id).not_withdrawn
      end
    end
  end
end
