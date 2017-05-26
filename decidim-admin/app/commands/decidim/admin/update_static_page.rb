# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when updating a static page.
    class UpdateStaticPage < Rectify::Command
      # Public: Initializes the command.
      #
      # page - The StaticPage to update
      # form - A form object with the params.
      def initialize(page, form)
        @page = page
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        update_page
        broadcast(:ok)
      end

      private

      attr_reader :form

      def update_page
        @page.update_attributes!(attributes)
      end

      def attributes
        {
          title: form.title,
          slug: form.slug,
          content: form.content
        }
      end
    end
  end
end
