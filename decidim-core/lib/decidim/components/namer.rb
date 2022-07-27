# frozen_string_literal: true

module Decidim
  module Components
    # This class automatically names components for the given organization.
    # In order to do so, it uses the i18n keys of the component, fallback to English,
    # searching for the key `"decidim.components.<component name>.name"`
    #
    # This is intended to be used from the component seeds section.
    #
    # Examples:
    #
    #   Decidim::Component.create!(
    #     participatory_space: process,
    #     name: Decidim::Component::Namer.new(organization.available_locales, :my_component_name).i18n_name
    #     manifest_name: :my_component_name
    #   )
    class Namer
      def initialize(locales, component_name)
        @locales = locales
        @component_name = component_name
      end

      def i18n_name
        locales.inject({}) do |names, locale|
          names.update(locale => I18n.t("decidim.components.#{component_name}.name", locale:))
        end
      end

      private

      attr_reader :locales, :component_name
    end
  end
end
