# frozen_string_literal: true

module Decidim
  module Verifications
    # Renders the "Revoke verifications" block for a verification method:
    # option cards with live counts and an optional before-date filter.
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

      def total_count
        options[:total].to_i
      end

      def impersonated_count
        options[:impersonated].to_i
      end

      def option_field_id(option)
        "revocations_#{workflow.key}_#{option}"
      end

      def confirm_text(key)
        t("decidim.admin.menu.authorization_revocation.destroy.#{key}", workflow: workflow.fullname, count: "%{count}", date: "%{date}")
      end

      def decidim_verifications
        Decidim::Verifications::Engine.routes.url_helpers
      end
    end
  end
end
