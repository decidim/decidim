# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when updating a static page.
    class UpdateStaticPage < Decidim::Commands::UpdateResource
      fetch_form_attributes :title, :slug, :weight, :topic, :content, :allow_public_access

      private

      def run_after_hooks
        return unless form.changed_notably

        UpdateOrganizationTosVersion.call(form.organization, resource, form)
      end
    end
  end
end
