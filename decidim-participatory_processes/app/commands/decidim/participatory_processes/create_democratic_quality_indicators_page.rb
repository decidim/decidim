# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    class CreateDemocraticQualityIndicatorsPage < Decidim::Command
      # Public: Initializes the command.
      #
      # @param organization_id [Integer] an id to fetch a Decidim::Organization instance
      def initialize(organization_id)
        @organization = Decidim::Organization.find(organization_id)
      end

      # Executes the command that creates the required static page or returns it if it already exists.
      #
      # @return [Decidim::StaticPage]
      def call
        StaticPage.find_or_create_by!(organization:, slug: "democratic-quality-indicators") do |page|
          page.decidim_organization_id = organization.id
          page.title = localized_attribute(organization, :title)
          page.content = localized_attribute(organization, :content)
          page.allow_public_access = true
        end
      end

      private

      attr_reader :organization

      def localized_attribute(organization, attribute)
        organization.available_locales.inject({}) do |result, locale|
          text = I18n.with_locale(locale) do
            I18n.t(attribute, scope: "decidim.participatory_processes.static_pages.democratic_quality_indicators")
          end

          result.update(locale => text)
        end
      end
    end
  end
end
