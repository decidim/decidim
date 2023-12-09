# frozen_string_literal: true

module Decidim
  module Admin
    # This command gets called when a component is created from the admin panel.
    class CreateComponent < Decidim::Commands::CreateResource
      attr_reader :manifest, :participatory_space

      fetch_form_attributes :name, :participatory_space, :weight, :settings, :default_step_settings, :step_settings

      # Public: Initializes the command.
      #
      # form - The form from which the data in this component comes from.
      def initialize(form)
        super(form)
        @manifest = form.manifest
      end

      protected

      def resource_class = Decidim::Component

      def attributes = super.merge({ manifest_name: manifest.name })

      def run_after_hooks = manifest.run_hooks(:create, component)
    end
  end
end
