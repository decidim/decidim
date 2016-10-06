# frozen_string_literal: true
module Decidim
  module Admin
    # A command with all the business logic when creating a new participatory
    # process in the system.
    class CreateParticipatoryProcess < Rectify::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      # organization - The Organization of the user that created the
      #   participatory process
      def initialize(form, organization)
        @form = form
        @organization = organization
      end

      # Executes the command. Braodcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        create_participatory_process
        broadcast(:ok)
      end

      private

      attr_reader :form

      def create_participatory_process
        ParticipatoryProcess.create!(
          title: form.title,
          subtitle: form.subtitle,
          slug: form.slug,
          hashtag: form.hashtag,
          description: form.description,
          short_description: form.short_description,
          organization: @organization
        )
      end
    end
  end
end
