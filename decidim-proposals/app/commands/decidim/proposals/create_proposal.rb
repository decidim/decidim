# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic when a user creates a new proposal.
    class CreateProposal < Decidim::Command
      include ::Decidim::MultipleAttachmentsMethods
      include HashtagsMethods

      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # current_user - The current user.
      # coauthorships - The coauthorships of the proposal.
      def initialize(form, current_user, coauthorships = nil)
        @form = form
        @current_user = current_user
        @coauthorships = coauthorships
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the proposal.
      # - :invalid if the form was not valid and we could not proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        if proposal_limit_reached?
          form.errors.add(:base, I18n.t("decidim.proposals.new.limit_reached"))
          return broadcast(:invalid)
        end

        if process_attachments?
          build_attachments
          return broadcast(:invalid) if attachments_invalid?
        end

        with_events(with_transaction: true) do
          create_proposal
          create_attachments(first_weight: first_attachment_weight) if process_attachments?
        end

        broadcast(:ok, proposal)
      end

      private

      attr_reader :form, :proposal, :attachment

      def event_arguments
        {
          resource: proposal,
          extra: {
            event_author: form.current_user,
            locale:
          }
        }
      end

      # Prevent PaperTrail from creating an additional version
      # in the proposal multi-step creation process (step 1: create)
      #
      # A first version will be created in step 4: publish
      # for diff rendering in the proposal version control
      def create_proposal
        PaperTrail.request(enabled: false) do
          @proposal = Decidim.traceability.perform_action!(
            :create,
            Decidim::Proposals::Proposal,
            @current_user,
            visibility: "public-only"
          ) do
            proposal = Proposal.new(
              title: {
                I18n.locale => title_with_hashtags
              },
              body: {
                I18n.locale => body_with_hashtags
              },
              component: form.component
            )

            proposal.taxonomizations = form.taxonomizations if form.taxonomizations.present?
            proposal.documents = form.documents if form.documents.present?
            proposal.address = form.address if form.has_address? && !form.geocoded?
            proposal.add_coauthor(@current_user)
            proposal.save!
            @attached_to = proposal
            proposal
          end
        end
      end

      def proposal_limit_reached?
        return false if @coauthorships.present?

        proposal_limit = form.current_component.settings.proposal_limit

        return false if proposal_limit.zero?

        current_user_proposals.count >= proposal_limit
      end

      def organization
        @organization ||= @current_user.organization
      end

      def current_user_proposals
        Proposal.not_withdrawn.from_author(@current_user).where(component: form.current_component)
      end

      def first_attachment_weight
        return 1 if proposal.photos.count.zero?

        proposal.photos.count
      end
    end
  end
end
