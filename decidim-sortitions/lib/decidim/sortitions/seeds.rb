# frozen_string_literal: true

require "decidim/components/namer"

module Decidim
  module Sortitions
    class Seeds
      attr_reader :participatory_space

      def initialize(participatory_space:)
        @participatory_space = participatory_space
      end

      def call
        Decidim::Component.create!(
          name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :sortitions).i18n_name,
          manifest_name: :sortitions,
          published_at: Time.current,
          participatory_space:
        )
      end
    end
  end
end
