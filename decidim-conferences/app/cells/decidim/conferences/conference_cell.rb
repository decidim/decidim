# frozen_string_literal: true

module Decidim
  module Conferences
    # This cell renders the conference card for an instance of an Conference
    # the default size is the Medium Card (:m)
    class ConferenceCell < Decidim::ViewModel
      def show
        cell card_size, model
      end

      private

      def card_size
        "decidim/conferences/conference_m"
      end
    end
  end
end
