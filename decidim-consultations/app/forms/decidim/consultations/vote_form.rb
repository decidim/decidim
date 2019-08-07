# frozen_string_literal: true

module Decidim
  module Consultations
    class VoteForm < Form
      mimic :vote

      attribute :decidim_consultations_response_id, Integer

      validates :decidim_consultations_response_id, presence: true
      validate :response_exists

      def response
        @response ||= Response.find_by(id: decidim_consultations_response_id)
      end

      private

      def response_exists
        return unless response.nil?

        errors.add(
          :decidim_consultations_response_id,
          I18n.t("decidim_consultations_response_id.not_found", scope: "activemodel.errors.vote")
        )
      end
    end
  end
end
