# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Accountability
    # This cell renders the result card for an instance of a Result
    # the default size is the List Card (:l)
    class ResultCardCell < Decidim::ViewModel
      def show
        cell card_size, model, options
      end

      private

      def card_size
        "decidim/accountability/result_l"
      end
    end
  end
end
