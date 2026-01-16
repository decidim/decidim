# frozen_string_literal: true

module Decidim
  module Admin
    class AttachmentsPrivacyWarningCell < Decidim::ViewModel
      delegate :current_participatory_space, to: :controller

      private

      def private_space?
        current_participatory_space.restricted? || current_participatory_space.transparent?
      end

      def transparent_space?
        current_participatory_space.transparent?
      end
    end
  end
end
