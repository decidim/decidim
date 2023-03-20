# frozen_string_literal: true

module Decidim
  # Defines a relation between a user and an conference, and what kind of relation
  # does the user have.
  class ConferenceUserRole < ApplicationRecord
    include Traceable
    include Loggable
    include ParticipatorySpaceUser

    belongs_to :conference, foreign_key: "decidim_conference_id", class_name: "Decidim::Conference", optional: true
    alias participatory_space conference

    validates :role, inclusion: { in: ParticipatorySpaceUser::ROLES }, uniqueness: { scope: [:user, :conference] }
    def target_space_association = :conference

    def self.log_presenter_class_for(_log)
      Decidim::Conferences::AdminLog::ConferenceUserRolePresenter
    end
  end
end
