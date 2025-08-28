# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic for updating the current
    # organization.
    class UpdateOrganization < Decidim::Commands::UpdateResource
      fetch_file_attributes :logo, :favicon, :official_img_footer

      fetch_form_attributes :name, :description, :default_locale, :reference_prefix, :time_zone, :twitter_handler,
                            :facebook_handler, :instagram_handler, :youtube_handler, :github_handler, :badges_enabled,
                            :comments_max_length, :enable_machine_translations, :admin_terms_of_service_body,
                            :rich_text_editor_in_public_views, :enable_participatory_space_filters, :official_url,
                            :enable_omnipresent_banner, :omnipresent_banner_url, :omnipresent_banner_title,
                            :omnipresent_banner_short_description

      private

      def attributes
        super
          .merge(welcome_notification_attributes)
          .merge(machine_translation_attributes)
          .merge(colors_attributes)
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

      def colors_attributes
        {
          colors: {
            primary: form.primary_color,
            secondary: form.secondary_color,
            tertiary: form.tertiary_color
          }.compact_blank
        }
      end
    end
  end
end
