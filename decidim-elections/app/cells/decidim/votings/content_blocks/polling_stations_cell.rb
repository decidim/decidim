# frozen_string_literal: true

module Decidim
  module Votings
    module ContentBlocks
      class PollingStationsCell < Decidim::ViewModel
        include Decidim::MapHelper
        include Decidim::SanitizeHelper
        include Decidim::LayoutHelper
        include Decidim::IconHelper
        include Decidim::NeedsSnippets

        delegate :current_participatory_space,
                 :snippets,
                 to: :controller

        def show
          return if current_participatory_space.online_voting?

          render
        end

        private

        def polling_stations
          @polling_stations ||= current_participatory_space.polling_stations
        end
      end
    end
  end
end
