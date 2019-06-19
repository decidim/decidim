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
      attribute :amendable_params, Object

      validates :amendable_gid, presence: true
      validates :emendation_params, presence: true
      validate :emendation_changes_amendable
      validate :check_amendable_form_validations

      def emendation_changes_amendable
        return unless amendable.amendable_fields == [:title, :body]
        return unless present(amendable).title == present(emendation).title
        return unless present(amendable).body.strip == present(emendation).body.strip

        amendable_form.errors.add(:title, :identical)
        amendable_form.errors.add(:body, :identical)
      end

      def amendable
        @amendable ||= GlobalID::Locator.locate_signed(amendable_gid)
      end

      def emendation
        amendable.amendable_type.constantize.new(@emendation_params)
      end

      def amendable_params
        amendable.attributes.slice(*amendable.amendable_fields.map(&:to_s))
      end
    end
  end
end
