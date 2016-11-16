# frozen_string_literal: true
module Decidim
  module Admin
    class CreateComponent < Rectify::Command
      def initialize(form, participatory_process)
        @form = form
        @participatory_process = participatory_process
      end

      def call
        return broadcast(:invalid) if form.invalid?

        transaction do
          create_component
          run_hooks
        end

        broadcast(:ok)
      end

      private

      attr_reader :form

      def create_component
        @component = Component.create!(
          component_type: component_manifest.config[:name],
          name: form.name,
          participatory_process: @participatory_process
        )
      end

      def component_manifest
        @component_manifest ||= Decidim.components.find do |component|
          component.config[:name] == form.component_type.to_sym
        end
      end

      def run_hooks
        component_manifest.config.dig(:hooks, :create)&.call(@component)
      end
    end
  end
end
