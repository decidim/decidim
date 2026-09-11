# frozen_string_literal: true

module Decidim
  module Proposals
    class ImportBatchEvent < Decidim::Events::SimpleEvent
      def email_intro
        [
          I18n.t("email_intro", **import_i18n_options),
          "<br><br>",
          I18n.t("email_link", **import_i18n_options)
        ].join(" ").html_safe
      end

      def resource_path
        nil
      end

      def resource_url
        nil
      end

      private

      def import_i18n_options
        {
          scope: i18n_scope,
          participatory_space_title:,
          participatory_space_url:,
          imported_count:
        }
      end

      def imported_count
        extra[:imported_count].to_i
      end

      def participatory_space_title
        decidim_sanitize_translated(participatory_space&.title)
      end

      def participatory_space_url
        return unless participatory_space

        Decidim::ResourceLocatorPresenter.new(participatory_space).url
      end
    end
  end
end
