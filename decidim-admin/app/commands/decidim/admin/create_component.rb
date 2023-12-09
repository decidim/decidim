# frozen_string_literal: true

module Decidim
  module Admin
    # This command gets called when a component is created from the admin panel.
    class CreateComponent < Decidim::Commands::CreateResource
      fetch_form_attributes :name, :participatory_space, :weight, :settings, :default_step_settings, :step_settings

      private

      def attributes = super.reverse_merge({ manifest_name: form.manifest.name })

      def resource_class = Decidim::Component

      def run_after_hooks = form.manifest.run_hooks(:create, resource)
    end
  end
end
