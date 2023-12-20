# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic for updating the current
    # organization.
    class UpdateOrganization < Decidim::Commands::UpdateResource
      fetch_form_attributes :name, :default_locale, :reference_prefix, :time_zone, :twitter_handler,
                            :facebook_handler, :instagram_handler, :youtube_handler, :github_handler, :badges_enabled,
                            :user_groups_enabled, :comments_max_length, :enable_machine_translations,
                            :admin_terms_of_service_body, :rich_text_editor_in_public_views, :enable_participatory_space_filters

      private

      def attributes
        super
          .merge(welcome_notification_attributes)
          .merge(machine_translation_attributes)
      end

      def welcome_notification_attributes
        {
          send_welcome_notification: form.send_welcome_notification,
          welcome_notification_subject: form.customize_welcome_notification ? form.welcome_notification_subject : nil,
          welcome_notification_body: form.customize_welcome_notification ? form.welcome_notification_body : nil
        }
      end

      def machine_translation_attributes
        return {} unless Decidim.config.enable_machine_translations

        {
          machine_translation_display_priority: form.machine_translation_display_priority
        }
      end
    end
  end
end
