# frozen_string_literal: true

require "decidim/components/namer"

module Decidim
  module Pages
    class Seeds
      attr_reader :participatory_space

      def initialize(participatory_space:)
        @participatory_space = participatory_space
      end

      def call
        component = Decidim::Component.create!(
          name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :pages).i18n_name,
          manifest_name: :pages,
          published_at: Time.current,
          participatory_space:
        )

        Decidim::Pages::Page.create!(
          component:,
          body: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(sentence_count: 3)
          end
        )
      end
    end
  end
end
