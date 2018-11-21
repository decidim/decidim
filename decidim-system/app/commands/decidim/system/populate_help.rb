# frozen_string_literal: true

module Decidim
  module System
    # A command with all the business logic when creating a new organization in
    # the system. It creates the organization and invites the admin to the
    # system.
    class PopulateHelp < Rectify::Command
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
        ActiveRecord::Base.transaction do
          topic = Decidim::StaticPageTopic.create!(
            title: multi_translation("decidim.help.main_topic.title", organization: @organization.name),
            description: multi_translation("decidim.help.main_topic.description", organization: @organization.name),
            organization: @organization,
            weight: 0
          )

          Decidim::StaticPage.create!(
            slug: "help",
            title: multi_translation("decidim.help.main_topic.default_page.title", organization: @organization.name),
            content: multi_translation("decidim.help.main_topic.default_page.content", organization: @organization.name),
            topic: topic,
            organization: @organization,
            weight: 0
          )

          Decidim.participatory_space_manifests.each do |manifest|
            scope = "decidim.help.participatory_spaces.#{manifest.name}"
            next unless I18n.exists?(scope)

            Decidim::StaticPage.create!(
              title: multi_translation("#{scope}.title"),
              content: multi_translation("#{scope}.page"),
              slug: manifest.name,
              topic: topic,
              organization: @organization
            )

            ContextualHelpSection.set_content(@organization, manifest.name, multi_translation("#{scope}.contextual"))
          end
        end
      end

      def multi_translation(key, *arguments)
        Decidim::TranslationsHelper.multi_translation(key, @organization.available_locales, *arguments)
      end
    end
  end
end
