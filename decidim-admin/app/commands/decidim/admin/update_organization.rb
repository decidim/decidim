# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic for updating the current
    # organization.
    class UpdateOrganization < Rectify::Command
      # Public: Initializes the command.
      #
      # organization - The Organization that will be updated.
      # form - A form object with the params.
      def initialize(organization, form)
        @organization = organization
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

        return broadcast(:ok, @organization) if update_organization
        broadcast(:invalid)
      end

      private

      attr_reader :form, :organization

      def update_organization
        @organization.assign_attributes(attributes)
        @organization.save! if @organization.valid?
      end

      def attributes
        {
          name: form.name,
          default_locale: form.default_locale,
          reference_prefix: form.reference_prefix,
          twitter_handler: form.twitter_handler,
          facebook_handler: form.facebook_handler,
          instagram_handler: form.instagram_handler,
          youtube_handler: form.youtube_handler,
          github_handler: form.github_handler
        }
      end
    end
  end
end
