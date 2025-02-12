# frozen_string_literal: true

require "decidim/components/namer"
require "decidim/seeds"

module Decidim
  module CollaborativeTexts
    class Seeds < Decidim::Seeds
      attr_reader :participatory_space

      def initialize(participatory_space:)
        @participatory_space = participatory_space
      end

      def call
        component = create_component!

        3.times do
          create_document!(component:)
        end

        2.times do
          create_document!(component:, published_at: nil)
        end
      end

      def create_component!
        params = {
          name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :collaborative_texts).i18n_name,
          manifest_name: :collaborative_texts,
          published_at: Time.current,
          participatory_space: participatory_space
        }

        Decidim.traceability.perform_action!(
          "publish",
          Decidim::Component,
          admin_user,
          visibility: "all"
        ) do
          Decidim::Component.create!(params)
        end
      end

      def create_document!(component:, published_at: Time.current)
        params = {
          component:,
          title: Decidim::Faker::Localized.paragraph,
          published_at:,
          accepting_suggestions: [true, false].sample
        }

        Decidim.traceability.create!(
          Decidim::CollaborativeTexts::Document,
          admin_user,
          params,
          visibility: "all"
        )
      end
    end
  end
end
