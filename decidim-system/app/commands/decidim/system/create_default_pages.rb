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
      # i18n-tasks-use t('decidim.system.default_pages.terms-of-service')
      #
      # Returns nothing.
      def call
        Decidim::StaticPage::DEFAULT_PAGES.map do |slug|
          static_page = Decidim::StaticPage.find_or_create_by!(organization:, slug:) do |page|
            translated_slug = I18n.t(slug, scope: "decidim.system.default_pages")
            page.title = localized_attribute(translated_slug, :title)
            page.content = localized_attribute(translated_slug, :content)
            page.show_in_footer = true
            page.allow_public_access = true if slug == "terms-of-service"
          end

          create_summary_content_blocks_for(static_page) if slug == "terms-of-service"
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

      def create_summary_content_blocks_for(page)
        content_block_summary = Decidim::ContentBlock.create(
          organization:,
          scope_name: :static_page,
          manifest_name: :summary,
          weight: 1,
          scoped_resource_id: page.id,
          published_at: Time.current
        )

        translated_slug = I18n.t(page.slug, scope: "decidim.system.default_pages")
        content_block_summary.settings = { summary: localized_attribute(translated_slug, :summary) }
        content_block_summary.save!
      end
    end
  end
end
