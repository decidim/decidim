# frozen_string_literal: true

module Decidim
  module Initiatives
    # Helper methods for the create initiative wizard.
    module CreateInitiativeHelper
      def signature_type_options(initiative_form)
        return all_signature_type_options unless initiative_form.signature_type_updatable?

        type = ::Decidim::InitiativesType.find(initiative_form.type_id)
        allowed_signatures = type.allowed_signature_types_for_initiatives

        case allowed_signatures
        when %w(online)
          online_signature_type_options
        when %w(offline)
          offline_signature_type_options
        else
          all_signature_type_options
        end
      end

      private

      def online_signature_type_options
        [
          [
            I18n.t(
              "online",
              scope: "activemodel.attributes.initiative.signature_type_values"
            ), "online"
          ]
        ]
      end

      def offline_signature_type_options
        [
          [
            I18n.t(
              "offline",
              scope: "activemodel.attributes.initiative.signature_type_values"
            ), "offline"
          ]
        ]
      end

      def all_signature_type_options
        Initiative.signature_types.keys.map do |type|
          [
            I18n.t(
              type,
              scope: "activemodel.attributes.initiative.signature_type_values"
            ), type
          ]
        end
      end
    end
  end
end
