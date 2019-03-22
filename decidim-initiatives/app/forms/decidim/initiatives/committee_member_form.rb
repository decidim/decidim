# frozen_string_literal: true

module Decidim
  module Initiatives
    # A form object used to collect the data for a new initiative committee
    # member.
    class CommitteeMemberForm < Form
      mimic :initiatives_committee_member

      attribute :initiative_id, Integer
      attribute :user_id, Integer
      attribute :state, String

      validates :initiative_id, presence: true
      validates :user_id, presence: true
      validates :state, inclusion: { in: %w(requested rejected accepted) }, unless: :user_is_author?
      validates :state, inclusion: { in: %w(rejected accepted) }, if: :user_is_author?

      def user_is_author?
        initiative&.decidim_author_id == user_id
      end

      private

      def initiative
        @initiative ||= Decidim::Initiative.find_by(id: initiative_id)
      end
    end
  end
end
