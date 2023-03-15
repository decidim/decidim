# frozen_string_literal: true

module Decidim
  module Conferences
    # This cell renders the conference card for an instance of an Conference
    # the default size is the Medium Card (:m)
    class ConferenceCell < Decidim::ViewModel
      def show
        cell card_size, model, options
      end

      private

      # REDESIGN_PENDING: size :m is deprecated
      def card_size
        case @options[:size]
        when :m
          "decidim/conferences/conference_m"
        else
          "decidim/conferences/conference_g"
        end
      end
    end
  end
end
