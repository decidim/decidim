# frozen_string_literal: true

module Decidim
  module Consultations
    class QuestionTitleScrubber < Decidim::UserInputScrubber
      private

      def custom_allowed_tags
        %w(strong em u b i br ul ol li p a code)
      end

      def custom_allowed_attributes
        %w(class href target rel)
      end
    end
  end
end
