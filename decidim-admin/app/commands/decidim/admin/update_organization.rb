# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic for updating the current
    # organization.
    class UpdateOrganization < Decidim::Command
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
        @organization = Decidim.traceability.update!(
          @organization,
          form.current_user,
          attributes
        )
      end

      def attributes
        {
          name: form.name,
          default_locale: form.default_locale,
          reference_prefix: form.reference_prefix,
          time_zone: form.time_zone,
          twitter_handler: form.twitter_handler,
          facebook_handler: form.facebook_handler,
          instagram_handler: form.instagram_handler,
          youtube_handler: form.youtube_handler,
          github_handler: form.github_handler,
          badges_enabled: form.badges_enabled,
          user_groups_enabled: form.user_groups_enabled,
          comments_max_length: form.comments_max_length,
          enable_machine_translations: form.enable_machine_translations,
          admin_terms_of_use_body: form.admin_terms_of_use_body,
          rich_text_editor_in_public_views: form.rich_text_editor_in_public_views,
          enable_participatory_space_filters: form.enable_participatory_space_filters
        }.merge(welcome_notification_attributes)
          .merge(machine_translation_attributes || {})
      end

      def welcome_notification_attributes
        {
          send_welcome_notification: form.send_welcome_notification,
          welcome_notification_subject: form.customize_welcome_notification ? form.welcome_notification_subject : nil,
          welcome_notification_body: form.customize_welcome_notification ? form.welcome_notification_body : nil
        }
      end

      def machine_translation_attributes
        return unless Decidim.config.enable_machine_translations

        {
          machine_translation_display_priority: form.machine_translation_display_priority
        }
      end
    end
  end
end
