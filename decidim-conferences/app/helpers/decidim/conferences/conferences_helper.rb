# frozen_string_literal: true

module Decidim
  module Conferences
    # Helpers related to the Conferences layout.
    module ConferencesHelper
      include Decidim::ResourceHelper

      def participatory_spaces_for_conference(conference_participatory_spaces)
        cell("decidim/conferences/participatory_spaces", conference_participatory_spaces)
      end
    end
  end
end
