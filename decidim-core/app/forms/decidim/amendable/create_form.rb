# frozen_string_literal: true

module Decidim
  module Amendable
    # A form object to be used when users want to amend an amendable resource.
    class CreateForm < Decidim::Amendable::Form
      mimic :amendment

      attribute :amendable_gid, String
      attribute :user_group_id, Integer
      attribute :emendation_params, Object

      validates :amendable_gid, presence: true
      validates :emendation_params, presence: true
      validate :emendation_changes_amendable
      validate :check_amendable_form_validations

      def emendation_changes_amendable
        return unless amendable.amendable_fields == [:title, :body]
        return unless get_value(amendable, :title) == get_value(emendation, :title)
        return unless get_value(amendable, :body).delete("\r") == get_value(emendation, :body).delete("\r")
        errors.add(:title, "AND body cannot be identical")
        errors.add(:body, "AND title cannot be identical")
      end

      def emendation
        amendable.amendable_type.constantize.new(@emendation_params)
      end

      def user_group
        return unless current_organization.user_groups_enabled? && user_group_id

        @user_group ||= Decidim::UserGroup.find_by(id: user_group_id, organization: current_organization)
      end
    end
  end
end
