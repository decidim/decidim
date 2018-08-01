# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic when a user updates a collaborative_draft.
    class UpdateCollaborativeDraft < Rectify::Command
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
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?
        return broadcast(:invalid) unless collaborative_draft.editable_by?(current_user)

        transaction do
          update_collaborative_draft
        end

        broadcast(:ok, collaborative_draft)
      end

      private

      attr_reader :form, :collaborative_draft, :current_user

      def update_collaborative_draft
        Decidim.traceability.update!(
          @collaborative_draft,
          @current_user,
          attributes
        )
      end

      def attributes
        {
          title: @form.title,
          body: @form.body,
          category: @form.category,
          scope: @form.scope,
          address: @form.address,
          latitude: @form.latitude,
          longitude: @form.longitude
        }
      end
    end
  end
end
