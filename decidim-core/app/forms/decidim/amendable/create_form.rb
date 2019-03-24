# frozen_string_literal: true

module Decidim
  module Amendable
    # A form object to be used when users want to amend an amendable resource.
    class CreateForm < Decidim::Amendable::Form
      include Decidim::ApplicationHelper

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
        return unless present(amendable).title == present(emendation).title
        return unless present(amendable).body.delete("\r") == present(emendation).body.delete("\r")

        errors.add(:title, "AND body cannot be identical")
        errors.add(:body, "AND title cannot be identical")
      end

      def amendable
        @amendable ||= GlobalID::Locator.locate_signed(amendable_gid)
      end

      def emendation
        amendable.amendable_type.constantize.new(@emendation_params)
      end
    end
  end
end
