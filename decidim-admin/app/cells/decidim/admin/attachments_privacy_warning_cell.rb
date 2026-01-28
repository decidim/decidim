# frozen_string_literal: true

module Decidim
  module Admin
    class AttachmentsPrivacyWarningCell < Decidim::ViewModel
      delegate :current_participatory_space, to: :controller

      private

      def restricted_space?
        current_participatory_space.respond_to?(:restricted?) && current_participatory_space.restricted?
      end
    end
  end
end
