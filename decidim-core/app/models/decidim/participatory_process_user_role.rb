# frozen_string_literal: true

module Decidim
  # Defines a relation between a user and a participatory process, and what
  # kind of relation does the user has.
  class ParticipatoryProcessUserRole < ApplicationRecord
    belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User", optional: true
    belongs_to :participatory_process, foreign_key: "decidim_participatory_process_id", class_name: "Decidim::ParticipatoryProcess", optional: true

    ROLES = %w(admin collaborator moderator).freeze
    validates :role, inclusion: { in: ROLES }, uniqueness: { scope: [:user, :participatory_process] }
    validate :user_and_participatory_process_same_organization

    private

    # Private: check if the process and the user have the same organization
    def user_and_participatory_process_same_organization
      return if !participatory_process || !user
      errors.add(:participatory_process, :invalid) unless user.organization == participatory_process.organization
    end
  end
end
