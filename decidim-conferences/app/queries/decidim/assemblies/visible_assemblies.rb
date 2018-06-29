# frozen_string_literal: true

module Decidim
  module Conferences
    # This query class filters conferences given a current_user.
    class VisibleConferences < Rectify::Query
      def query
        Decidim::Conference.public_spaces
      end
    end
  end
end
