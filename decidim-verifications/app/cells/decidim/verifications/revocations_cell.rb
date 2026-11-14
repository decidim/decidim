# frozen_string_literal: true

module Decidim
  module Verifications
    # This cell renders the "Revoke verifications" block of a verification method.
    class RevocationsCell < Decidim::ViewModel
      def show
        render
      end

      private

      def workflow
        model
      end

      def form
        @form ||= Decidim::Verifications::Admin::RevocationsForm.from_params(name: workflow.name)
      end

      def revocation_options
        [
          { key: "total", value: false, label: t("decidim.admin.menu.authorization_revocation.total_verified"), count: options[:total].to_i },
          { key: "impersonated", value: true, label: t("decidim.admin.menu.authorization_revocation.impersonated_only"), count: options[:impersonated].to_i }
        ].map { |option| option.merge(confirm_message: confirm_message(option), callout_message: callout_message(option)) }
      end

      def nothing_to_revoke?
        options[:total].to_i.zero?
      end

      def confirm_message(option)
        t("decidim.admin.menu.authorization_revocation.destroy.confirm_message.#{option[:key]}.all_html", count: option[:count], workflow: workflow.fullname)
      end

      def callout_message(option)
        t("decidim.admin.menu.authorization_revocation.callout.#{option[:key]}.all", count: option[:count])
      end

      def option_field_id(option)
        "revocations_#{workflow.key}_#{option}"
      end

      def decidim_verifications
        Decidim::Verifications::Engine.routes.url_helpers
      end
    end
  end
end
