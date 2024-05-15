# frozen_string_literal: true

module Decidim
  module Conferences
    # This cell renders the conference card for an instance of a Conference
    # the default size is the Grid Card (:g)
    class ConferenceCell < Decidim::ViewModel
      def show
        cell card_size, model, options
      end

      private

      def card_size
        case @options[:size]
        when :s
          "decidim/conferences/conference_s"
        else
          "decidim/conferences/conference_g"
        end
      end
    end
  end
end
