# frozen_string_literal: true

module Decidim
  module Votings
    class VotingMapCell < VotingGCell
      include Decidim::MapHelper
      include Decidim::Votings::MapHelper

      delegate :snippets, to: :controller

      def show
        return unless Decidim::Map.available?(:geocoding, :dynamic)

        render
      end

      def polling_stations
        model
      end

      private

      def cache_hash
        nil
      end
    end
  end
end
