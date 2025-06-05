# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic when a user creates a new collaborative draft.
    class CreateCollaborativeDraft < Decidim::Command
      include ::Decidim::MultipleAttachmentsMethods

      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # current_user - The current user.
      def initialize(form, current_user)
        @form = form
        @current_user = current_user
        @attached_to = nil
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the collaborative draft.
      # - :invalid if the form was not valid and we could not proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        if process_attachments?
          build_attachments
          return broadcast(:invalid) if attachments_invalid?
        end

        with_events(with_transaction: true) do
          create_collaborative_draft
          create_attachments if process_attachments?
        end

        broadcast(:ok, collaborative_draft)
      end

      private

      attr_reader :form, :collaborative_draft, :attachment

      def event_arguments
        {
          resource: collaborative_draft,
          extra: {
            event_author: form.current_user,
            locale:
          }
        }
      end

      def create_collaborative_draft
        @collaborative_draft = Decidim.traceability.perform_action!(
          :create,
          CollaborativeDraft,
          @form.current_user,
          visibility: "public-only"
        ) do
          draft = CollaborativeDraft.new(
            title: Decidim::ContentProcessor.parse(form.title, current_organization: form.current_organization).rewrite,
            body: Decidim::ContentProcessor.parse(form.body, current_organization: form.current_organization).rewrite,
            taxonomizations: form.taxonomizations,
            component: form.component,
            address: form.address,
            latitude: form.latitude,
            longitude: form.longitude,
            state: "open"
          )
          draft.coauthorships.build(author: @current_user)
          draft.save!
          draft
        end

        @attached_to = @collaborative_draft
      end

      def organization
        @organization ||= @current_user.organization
      end
    end
  end
end
