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
        # add seeds here
      end
    end
  end
end
