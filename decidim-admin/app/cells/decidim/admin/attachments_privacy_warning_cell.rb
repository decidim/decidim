# frozen_string_literal: true

module Decidim
  module Admin
    class AttachmentsPrivacyWarningCell < Decidim::ViewModel
      delegate :current_participatory_space, to: :controller

      private

      def private_space?
        current_participatory_space.private_space if current_participatory_space.respond_to?(:private_space)
      end

      def transparent_space?
        current_participatory_space.is_transparent if current_participatory_space.respond_to?(:is_transparent)
      end
    end
  end
end
