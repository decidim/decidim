# frozen_string_literal: true

module Decidim
  module Commands
    # Deletes a blob and the records which represent the uploaded file.
    #
    # The deletion is performed through the traceability service, so the action is
    # logged like any other resource deletion.
    class DeleteBlob < ::Decidim::Command
      # Initializes the command.
      #
      # @param blob [ActiveStorage::Blob] the blob to delete.
      # @param current_user [Decidim::User] the current user.
      def initialize(blob, current_user)
        @blob = blob
        @current_user = current_user
      end

      # Deletes the blob.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) if invalid?

        run_before_hooks
        destroy_blob
        run_after_hooks

        broadcast(:ok, blob)
      rescue Decidim::Commands::HookError, StandardError
        broadcast(:invalid)
      end

      protected

      attr_reader :blob, :current_user

      # An unattached blob has no organization to attribute the action to, so it is
      # not deleted.
      def invalid?
        blob.attachments.empty?
      end

      def destroy_blob
        Decidim.traceability.perform_action!(:delete, blob, current_user) do
          blob.attachments.to_a.each do |attachment|
            record = attachment.record
            record.is_a?(Decidim::Attachment) ? record.destroy : attachment.destroy
          end

          blob.purge_later
        end
      end

      # Useful for running any code that you may want to execute before deleting the blob.
      def run_before_hooks; end

      # Useful for running any code that you may want to execute after deleting the blob.
      def run_after_hooks; end
    end
  end
end
