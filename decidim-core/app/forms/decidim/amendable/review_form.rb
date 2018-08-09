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

      validates :id, :amendable_gid, :emendation_gid, presence: true

      def amendable_gid
        amendment.amendable.to_gid.to_s
      end

      def emendation_gid
        amendment.emendation.to_gid.to_s
      end
    end
  end
end
