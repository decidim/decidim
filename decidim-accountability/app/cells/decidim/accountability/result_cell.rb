# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Accountability
    # This cell renders the result card for an instance of a Result
    # the default size is the Medium Card (:m)
    class ResultCell < Decidim::ViewModel
      def show
        cell card_size, model, options
      end

      private

      def card_size
        "decidim/accountability/result_m"
      end
    end
  end
end
