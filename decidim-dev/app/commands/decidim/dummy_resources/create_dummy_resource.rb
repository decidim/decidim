# frozen_string_literal: true

module Decidim
  module DummyResources
    class CreateDummyResource < Decidim::Command
      include Decidim::AttachmentMethods
      include Decidim::GalleryMethods

      def initialize(form)
        @form = form
      end

      # Creates the dummy_resource if valid.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) if @form.invalid?

        if process_gallery?
          build_gallery
          return broadcast(:invalid) if gallery_invalid?
        end

        transaction do
          create_dummy_resource
          create_gallery if process_gallery?
        end

        broadcast(:ok)
      end

      private

      attr_reader :form, :dummy_resource, :gallery

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
