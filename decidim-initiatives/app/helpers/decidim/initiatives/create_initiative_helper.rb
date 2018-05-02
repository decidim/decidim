# frozen_string_literal: true

module Decidim
  module Initiatives
    # Helper methods for the create initiative wizard.
    module CreateInitiativeHelper
      def signature_type_options
        return online_signature_type_options unless Decidim::Initiatives.face_to_face_voting_allowed
        return offline_signature_type_options unless Decidim::Initiatives.online_voting_allowed

        options = []
        Initiative.signature_types.each_key do |type|
          options << [
            I18n.t(
              type,
              scope: %w(activemodel attributes initiative signature_type_values)
            ), type
          ]
        end
        options
      end

      def online_signature_type_options
        [
          [
            I18n.t(
              "online",
              scope: %w(activemodel attributes initiative signature_type_values)
            ), "online"
          ]
        ]
      end

      def offline_signature_type_options
        [
          [
            I18n.t(
              "offline",
              scope: %w(activemodel attributes initiative signature_type_values)
            ), "offline"
          ]
        ]
      end
    end
  end
end
