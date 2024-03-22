# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when creating a static page.
    class CreateStaticPage < Decidim::Commands::CreateResource
      fetch_form_attributes :organization, :title, :slug, :show_in_footer, :weight, :topic, :content, :allow_public_access

      protected

      def resource_class = Decidim::StaticPage

      def run_after_hooks
        UpdateOrganizationTosVersion.call(form.organization, resource, form)
      end
    end
  end
end
