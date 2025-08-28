# frozen_string_literal: true

module Decidim
  module Core
    class StatisticType < Decidim::Api::Types::BaseObject
      description "Represents a single statistic"

      field :description, Decidim::Core::TranslatedFieldType, "The description of the statistic calculation", null: true
      field :key, GraphQL::Types::String, "The unique key of the statistic", null: false
      field :name, Decidim::Core::TranslatedFieldType, "The name of the statistic", null: true
      field :value, GraphQL::Types::Int, "The actual value of the statistic", null: false

      def organization
        object[0]
      end

      def stat
        object[1]
      end

      def key
        stat[:name]
      end

      def value
        stat[:data][0]
      end

      def name
        organization.available_locales.to_h do |locale|
          I18n.with_locale(locale) do
            [locale, I18n.t(key, scope: "decidim.statistics")]
          end
        end
      end

      def description
        organization.available_locales.to_h do |locale|
          I18n.with_locale(locale) do
            [locale, I18n.t(stat[:tooltip_key], scope: "decidim.statistics")]
          end
        end
      end
    end
  end
end
