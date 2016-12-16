# frozen_string_literal: true

module Decidim
  module Features
    # This class automatically names features for the given organization.
    # In order to do so, it uses the i18n keys of the feature, fallback to English,
    # searching for the key `"decidim.features.<feature name>.name"`
    #
    # This is intended to be used from the feature seeds section.
    #
    # Examples:
    #
    #   Decidim::Feature.create!(
    #     participatory_process: process,
    #     name: Decidim::Feature::Namer.new(process.organization, :my_feature_name).i18n_name
    #     manifest_name: :my_feature_name
    #   )
    class Namer
      def initialize(organization, feature_name)
        @organization = organization
        @feature_name = feature_name
      end

      def i18n_name
        locales.inject({}) do |names, locale|
          names.update(locale => I18n.t("decidim.features.#{feature_name}.name", locale: locale))
        end
      end

      private

      attr_reader :organization, :feature_name

      def locales
        organization.available_locales
      end
    end
  end
end
