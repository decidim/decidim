# frozen_string_literal: true
module Decidim
  module Admin
    # A command with all the business logic when creating a new participatory
    # process in the system.
    class UpdateParticipatoryProcess < Rectify::Command
      # Public: Initializes the command.
      #
      # participatory_process - the ParticipatoryProcess to update
      # form - A form object with the params.
      def initialize(participatory_process, form)
        @participatory_process = participatory_process
        @form = form
      end

      # Executes the command. Braodcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        update_participatory_process
        broadcast(:ok)
      end

      private

      attr_reader :form

      def update_participatory_process
        @participatory_process.update_attributes!(attributes)
      end

      def attributes
        {
          title: form.title,
          subtitle: form.subtitle,
          slug: form.slug,
          hashtag: form.hashtag,
          description: form.description,
          short_description: form.short_description
        }
      end
    end
  end
end
