# frozen_string_literal: true

module Decidim
  module Amendable
    # A form object to be used when users want to amend an amendable resource.
    class CreateForm < Decidim::Amendable::Form
      mimic :amend

      attribute :amendable_gid, String
      attribute :user_group_id, Integer
      attribute :emendation_fields, Object
      attribute :title, String
      attribute :body, String

      validates :amendable_gid, presence: true
      validates :title, :body, presence: true, etiquette: true
      validates :title, length: { maximum: 150 }

      def title
        @title ||= emendation_fields[:title]
      end

      def body
        @body ||= emendation_fields[:body]
      end

      def amendable
        @amendable ||= GlobalID::Locator.locate_signed amendable_gid
      end

      def amendable_type
        amendable.resource_manifest.model_class_name
      end

      def emendation_type
        amendable_type
      end

      def amender
        current_user
      end

      def user_group
        return unless current_organization.user_groups_enabled? && user_group_id

        @user_group ||= Decidim::UserGroup.find_by(id: user_group_id, organization: current_organization)
      end

      def emendation_fields
        @emendation_fields ||= amendable.form.from_model(amendable)
      end
    end
  end
end
