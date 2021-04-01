# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # A form to create/edit a ballot style
      class BallotStyleForm < Form
        attribute :title, String
        attribute :code, String
        attribute :question_ids, Array[Integer]

        validates :code, presence: true
        validate :code_uniqueness

        private

        def code_uniqueness
          return unless voting_ballot_styles
                        .where(code: code)
                        .where.not(id: context[:ballot_style_id])
                        .any?

          errors.add(:code, :taken)
        end

        def voting_ballot_styles
          @voting_ballot_styles ||= context[:voting]&.ballot_styles || []
        end
      end
    end
  end
end
