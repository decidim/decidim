# frozen_string_literal: true

module Decidim
  module Consultations
    class QuestionTitleScrubber < Decidim::UserInputScrubber
      private

      def custom_allowed_tags
        Loofah::HTML5::SafeList::ACCEPTABLE_ELEMENTS - RESTRICTED_TAGS
      end
    end
  end
end
