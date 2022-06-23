# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to add an attachment to a
    # participatory process.
    class CreateAttachment < Decidim::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      # attached_to - The ActiveRecord::Base that will hold the attachment
      def initialize(form, attached_to, user)
        @form = form
        @attached_to = attached_to
        @user = user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        build_attachment

        if @attachment.valid?
          Decidim.traceability.perform_action!(:create, Decidim::Attachment, @user) do
            @attachment.save!
            notify_followers
            broadcast(:ok)
            @attachment
          end
        else
          @form.errors.add :file, @attachment.errors[:file] if @attachment.errors.has_key? :file
          broadcast(:invalid)
        end
      end

      private

      attr_reader :form

      def build_attachment
        @attachment = Attachment.new(
          title: form.title,
          description: form.description,
          attached_to: @attached_to,
          weight: form.weight,
          attachment_collection: form.attachment_collection,
          file: form.file, # Define attached_to before this
          content_type: blob(form.file).content_type
        )
      end

      def notify_followers
        return unless @attachment.attached_to.is_a?(Decidim::Followable)

        Decidim::EventsManager.publish(
          event: "decidim.events.attachments.attachment_created",
          event_class: Decidim::AttachmentCreatedEvent,
          resource: @attachment,
          followers: @attachment.attached_to.followers
        )
      end

      def blob(signed_id)
        ActiveStorage::Blob.find_signed(signed_id)
      end
    end
  end
end
