# frozen_string_literal: true

module Decidim
  module System
    # A command with all the business logic when creating a new organization in
    # the system. It creates the organization and invites the admin to the
    # system.
    class CreateDefaultPages < Decidim::Command
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
          Decidim::StaticPage.find_or_create_by!(organization:, slug:) do |page|
            page.title = localized_attribute(slug, :title)
            page.content = localized_attribute(slug, :content)
            page.show_in_footer = true
            page.allow_public_access = true if slug == "terms-and-conditions"
          end
        end
      end

      private

      attr_reader :organization

      def localized_attribute(slug, attribute)
        Decidim.available_locales.inject({}) do |result, locale|
          text = I18n.with_locale(locale) do
            I18n.t(attribute, scope: "decidim.system.default_pages.placeholders", page: slug)
          end

          result.update(locale => text)
        end
      end
    end
  end
end
