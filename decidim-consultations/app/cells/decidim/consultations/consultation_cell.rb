# frozen_string_literal: true

module Decidim
  module Consultations
    # This cell renders the card for an instance of a Question
    # the default size is the Medium Card (:m)
    class ConsultationCell < Decidim::ViewModel
      def show
        cell card_size, model, options
      end

      private

      # REDESIGN_PENDING: size :m is deprecated
      def card_size
        case @options[:size]
        when :s
          "decidim/consultations/consultation_s"
        else
          "decidim/consultations/consultation_m"
        end
      end
    end
  end
end
