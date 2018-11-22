# frozen_string_literal: true

module Decidim
  module Amendable
    # A form object to be used when users want to amend an amendable resource.
    class PromoteForm < Decidim::Amendable::Form
      mimic :amend

      attribute :emendation_fields, Object

      attribute :id, String

      validates :id, :emendation_fields, presence: true

      def emendation
        @emendation ||= Amendment.find_by(decidim_emendation_id: id).emendation
      end

      def amendable_type
        emendation_type
      end

      def emendation_type
        return unless emendation
        emendation.resource_manifest.model_class_name
      end

      def user_group
        return unless emendation_fields[:user_group_id]
        @user_group ||= Decidim::UserGroup.find_by(id: emendation_fields.user_group_id, organization: current_organization)
      end
    end
  end
end
