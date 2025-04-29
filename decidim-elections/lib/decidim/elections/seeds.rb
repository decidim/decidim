# frozen_string_literal: true

require "decidim/components/namer"

module Decidim
  module Elections
    class Seeds
      attr_reader :participatory_space

      def initialize(participatory_space:)
        @participatory_space = participatory_space
      end

      def call
        component = create_component!

        2.times do
          create_election!(component:)
        end
      end

      def create_component!
        params = {
          name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :elections).i18n_name,
          published_at: Time.current,
          manifest_name: :elections,
          participatory_space:,
          settings: {
            attachments_allowed: true
          }
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

      def create_election!(component:)
        params = {
          name: Decidim::Components::Namer.new(
            participatory_space.organization.available_locales,
            :elections
          ).i18n_name,
          component:,
          start_at: Time.current,
          end_at: 1.day.from_now
        }

        Decidim.traceability.perform_action!(
          "publish",
          Decidim::Elections::Election,
          admin_user,
          visibility: "all"
        ) do
          Decidim::Elections::Election.create!(params)
        end
      end
    end
  end
end
