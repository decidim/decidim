# frozen_string_literal: true

module Decidim
  module AdminLog
    # This class holds the logic to present a `Decidim::Organization`
    # for the `AdminLog` log.
    #
    # Usage should be automatic and you shouldn't need to call this class
    # directly, but here's an example:
    #
    #    action_log = Decidim::ActionLog.last
    #    view_helpers # => this comes from the views
    #    OrganizationPresenter.new(action_log, view_helpers).present
    class OrganizationPresenter < Decidim::Log::BasePresenter
      private

      def diff_fields_mapping
        return { external_domain_whitelist: :string } if action == "update_external_domain"

        settings_attributes_mapping
          .merge(omnipresent_banner_attributes_mapping)
          .merge(highlighted_content_banner_attributes_mapping)
          .merge(appearance_attributes_mapping)
          .merge(id_documents_attributes_mapping)
      end

      def settings_attributes_mapping
        {
          name: :string,
          default_locale: :locale,
          reference_prefix: :string,
          twitter_handler: :string,
          facebook_handler: :string,
          instagram_handler: :string,
          youtube_handler: :string,
          github_handler: :string,
          tos_version: :datetime
        }
      end

      def omnipresent_banner_attributes_mapping
        {
          enable_omnipresent_banner: :boolean,
          omnipresent_banner_url: :string,
          omnipresent_banner_short_description: :i18n,
          omnipresent_banner_title: :i18n
        }
      end

      def highlighted_content_banner_attributes_mapping
        {
          highlighted_content_banner_enabled: :boolean,
          highlighted_content_banner_action_url: :string,
          highlighted_content_banner_image: :string,
          highlighted_content_banner_title: :i18n,
          highlighted_content_banner_short_description: :i18n,
          highlighted_content_banner_action_title: :i18n,
          highlighted_content_banner_action_subtitle: :i18n
        }
      end

      def appearance_attributes_mapping
        {
          cta_button_path: :string,
          cta_button_text: :i18n,
          description: :i18n,
          logo: :string,
          header_snippets: :string,
          favicon: :string,
          official_img_header: :string,
          official_img_footer: :string,
          official_url: :string
        }
      end

      def id_documents_attributes_mapping
        {
          id_documents_methods: :string,
          id_documents_explanation_text: :i18n
        }
      end

      def action_string
        case action
        when "update_id_documents_config", "update_external_domain"
          "decidim.admin_log.organization.#{action}"
        else
          "decidim.admin_log.organization.update"
        end
      end

      def i18n_labels_scope
        "activemodel.attributes.organization"
      end

      def diff_actions
        super + %w(update_id_documents_config update_external_domain)
      end
    end
  end
end
