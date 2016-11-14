# frozen_string_literal: true
module Decidim
  module System
    # A command with all the business logic when creating a new organization in
    # the system. It creates the organization and invites the admin to the
    # system.
    class CreateDefaultPages < Rectify::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(organization)
        @organization = organization
      end

      # Executes the command.
      #
      # Returns nothing.
      def call
        Decidim::StaticPage::DEFAULT_PAGES.map do |slug|
          Decidim::StaticPage.find_or_create_by!(slug: slug) do |page|
            page.organization = organization
            page.title = localized_attribute(slug, :title)
            page.content = localized_attribute(slug, :content)
          end
        end
      end

      private

      attr_reader :organization

      def localized_attribute(slug, attribute)
        I18n.available_locales.inject({}) do |result, locale|
          text = I18n.with_locale(locale) do
            I18n.t(attribute, scope: "decidim.system.default_pages.placeholders", page: slug)
          end

          result.update(locale => text)
        end
      end
    end
  end
end
