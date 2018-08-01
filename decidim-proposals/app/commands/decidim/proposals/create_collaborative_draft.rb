# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic when a user creates a new collaborative draft.
    class CreateCollaborativeDraft < Rectify::Command
      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # current_user - The current user.
      def initialize(form, current_user)
        @form = form
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the collaborative draft.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        if process_attachments?
          build_attachment
          return broadcast(:invalid) if attachment_invalid?
        end

        transaction do
          create_collaborative_draft
          create_attachment if process_attachments?
        end

        broadcast(:ok, collaborative_draft)
      end

      private

      attr_reader :form, :collaborative_draft, :attachment

      def create_collaborative_draft
        @collaborative_draft = Decidim.traceability.create!(
          CollaborativeDraft,
          @form.current_user,
          title: form.title,
          body: form.body,
          category: form.category,
          scope: form.scope,
          component: form.component,
          address: form.address,
          latitude: form.latitude,
          longitude: form.longitude,
          state: "open"
        )

        @collaborative_draft.add_coauthor(@current_user, user_group: @form.user_group)
      end

      def build_attachment
        @attachment = Attachment.new(
          title: form.attachment.title,
          file: form.attachment.file,
          attached_to: @collaborative_draft
        )
      end

      def attachment_invalid?
        if attachment.invalid? && attachment.errors.has_key?(:file)
          form.attachment.errors.add :file, attachment.errors[:file]
          true
        end
      end

      def attachment_present?
        form.attachment.file.present?
      end

      def create_attachment
        attachment.attached_to = @collaborative_draft
        attachment.save!
      end

      def attachments_allowed?
        form.current_component.settings.attachments_allowed?
      end

      def process_attachments?
        attachments_allowed? && attachment_present?
      end

      def user_group
        @user_group ||= Decidim::UserGroup.find_by(organization: organization, id: form.user_group_id)
      end

      def organization
        @organization ||= @current_user.organization
      end
    end
  end
end
