# frozen_string_literal: true

module Decidim
  module Amendable
    # A form object used to review emendations
    class ReviewForm < Decidim::Amendable::Form
      mimic :amend

      attribute :id, String
      attribute :amendable_gid, String
      attribute :emendation_gid, String
      attribute :title, String
      attribute :body, String
      attribute :user_group_id, Integer
      attribute :emendation_fields, Object

      validates :id, :amendable_gid, :emendation_gid, presence: true

      def amendable_gid
        amendment.amendable.to_gid.to_s
      end

      def emendation_gid
        amendment.emendation.to_gid.to_s
      end

      def emendation_type
        emendation ||= GlobalID::Locator.locate_signed emendation_gid
        return unless emendation
        emendation.resource_manifest.model_class_name
      end
    end
  end
end
