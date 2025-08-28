# frozen_string_literal: true

module Decidim
  # Data store the committee members for the initiative
  class InitiativesCommitteeMember < ApplicationRecord
    belongs_to :initiative,
               foreign_key: "decidim_initiatives_id",
               class_name: "Decidim::Initiative",
               inverse_of: :committee_members

    belongs_to :user,
               foreign_key: "decidim_users_id",
               class_name: "Decidim::User"

    enum :state, [:requested, :rejected, :accepted]

    validates :state, presence: true
    validates :user, uniqueness: { scope: :initiative }

    scope :approved, -> { where(state: :accepted) }
    scope :non_deleted, -> { includes(:user).where(decidim_users: { deleted_at: nil }) }
    scope :excluding_author, -> { joins(:initiative).where.not("decidim_users_id = decidim_author_id") }
  end
end
