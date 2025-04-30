# frozen_string_literal: true

module Decidim
  module Amendable
    # A form object to be used when users want to amend an amendable resource.
    class CreateForm < Decidim::Amendable::Form
      mimic :amendment

      attribute :amendable_gid, String
      attribute :emendation_params, Hash

      validates :amendable_gid, presence: true
      validate :amendable_form_must_be_valid
      validate :emendation_must_change_amendable

      def amendable
        @amendable ||= GlobalID::Locator.locate_signed(amendable_gid)
      end
    end
  end
end
