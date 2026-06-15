# frozen_string_literal: true

module Decidim
  module Dev
    class CreateDummyResource < Decidim::Command
      include Decidim::MultipleAttachmentsMethods

      def initialize(form)
        @form = form
      end

      # Creates the dummy_resource if valid.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) if @form.invalid?

        if process_attachments?
          build_attachments
          return broadcast(:invalid) if attachments_invalid?
        end

        transaction do
          create_dummy_resource
          create_attachments if process_attachments?
        end

        broadcast(:ok)
      end

      private

      attr_reader :form, :dummy_resource, :attachments

      def create_dummy_resource
        @dummy_resource = DummyResource.create!(
          title: form.title,
          body: form.body,
          component: form.current_component,
          author: form.current_user
        )

        @attached_to = @dummy_resource
      end
    end
  end
end
