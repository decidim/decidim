# frozen_string_literal: true

module Decidim
  # Defines a relation between a user and an conference, and what kind of relation
  # does the user have.
  class ConferenceUserRole < ApplicationRecord
    include Traceable
    include Loggable

    belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User", optional: true
    belongs_to :conference, foreign_key: "decidim_conference_id", class_name: "Decidim::Conference", optional: true
    alias participatory_space conference

    ROLES = %w(admin collaborator moderator).freeze
    validates :role, inclusion: { in: ROLES }, uniqueness: { scope: [:user, :conference] }
    validate :user_and_conference_same_organization

    def self.log_presenter_class_for(_log)
      Decidim::Conferences::AdminLog::ConferenceUserRolePresenter
    end

    private

    # Private: check if the process and the user have the same organization
    def user_and_conference_same_organization
      return if !conference || !user
      errors.add(:conference, :invalid) unless user.organization == conference.organization
    end
  end
end
