# frozen_string_literal: true

module Decidim
  module Consultations
    # This class infers the current consultation we're scoped to by
    # looking at the request parameters and the organization in the request
    # environment, and injects it into the environment.
    class CurrentQuestion
      # Public: Matches the request against a question and injects it
      #         into the environment.
      #
      # request - The request that holds the question relevant
      #           information.
      #
      # Returns a true if the request matched, false otherwise
      def matches?(request)
        env = request.env

        @organization = env["decidim.current_organization"]
        return false unless @organization

        current_question(env, request.params) ? true : false
      end

      private

      def current_question(env, params)
        env["decidim.current_participatory_space"] ||= detect_current_question(params)
      end

      def detect_current_question(params)
        Decidim::Consultations::Question.find_by(slug: params[:question_slug], organization: @organization)
      end
    end
  end
end
