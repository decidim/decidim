# frozen_string_literal: true

module Decidim
  module Amendable
    # A form object to be used when users want to amend an amendable resource.
    class CreateForm < Decidim::Amendable::Form
      mimic :amendment

      attribute :amendable_gid, String
      attribute :user_group_id, Integer
      attribute :emendation_params, Hash

      validates :amendable_gid, presence: true
      validate :emendation_changes_amendable
      validate :check_amendable_form_validations

      def amendable
        @amendable ||= GlobalID::Locator.locate_signed(amendable_gid)
      end
    end
  end
end
