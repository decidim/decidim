# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic when a user updates a collaborative_draft.
    class UpdateCollaborativeDraft < Decidim::Command
      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # current_user - The current user.
      # collaborative_draft - the collaborative_draft to update.
      def initialize(form, current_user, collaborative_draft)
        @form = form
        @current_user = current_user
        @collaborative_draft = collaborative_draft
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the collaborative_draft.
      # - :invalid if the form was not valid and we could not proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?
        return broadcast(:invalid) unless collaborative_draft.editable_by?(current_user)

        with_events(with_transaction: true) do
          update_collaborative_draft
        end

        broadcast(:ok, collaborative_draft)
      end

      private

      attr_reader :form, :collaborative_draft, :current_user

      def event_arguments
        {
          resource: collaborative_draft,
          extra: {
            event_author: form.current_user,
            locale:
          }
        }
      end

      def update_collaborative_draft
        Decidim.traceability.update!(
          @collaborative_draft,
          @current_user,
          attributes,
          visibility: "public-only"
        )
      end

      def attributes
        {
          title: Decidim::ContentProcessor.parse(form.title, current_organization: form.current_organization).rewrite,
          body: Decidim::ContentProcessor.parse_with_processor(:inline_images, form.body, current_organization: form.current_organization).rewrite,
          taxonomizations: form.taxonomizations,
          address: form.address,
          latitude: form.latitude,
          longitude: form.longitude
        }
      end
    end
  end
end
