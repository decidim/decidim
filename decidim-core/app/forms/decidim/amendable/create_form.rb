# frozen_string_literal: true

module Decidim
  module Amendable
    # A form object to be used when users want to amend an amendable resource.
    class CreateForm < Decidim::Amendable::Form
      mimic :amend

      attribute :amendable_gid, String
      attribute :user_group_id, Integer
      attribute :emendation_fields, Object

      validates :amendable_gid, :amendable_type, :amender, presence: true

      def amendable
        @amendable ||= GlobalID::Locator.locate_signed amendable_gid
      end

      def amendable_type
        return unless amendable
        amendable.resource_manifest.model_class_name
      end

      def emendation_type
        amendable_type
      end

      def amender
        current_user
      end

      def user_group
        return unless user_group_id
        @user_group ||= Decidim::UserGroup.find_by(id: user_group_id, organization: current_organization)
      end
    end
  end
end
