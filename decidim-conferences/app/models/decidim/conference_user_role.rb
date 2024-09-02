# frozen_string_literal: true

module Decidim
  # Defines a relation between a user and a Conference, and what kind of relation
  # does the user have.
  class ConferenceUserRole < ApplicationRecord
    include Traceable
    include Loggable
    include ParticipatorySpaceUser

    belongs_to :conference, foreign_key: "decidim_conference_id", class_name: "Decidim::Conference", optional: true
    alias participatory_space conference

    scope :for_space, ->(participatory_space) { where(conference: participatory_space) }

    validates :role, inclusion: { in: ParticipatorySpaceUser::ROLES }, uniqueness: { scope: [:user, :conference] }
    def target_space_association = :conference

    def self.log_presenter_class_for(_log)
      Decidim::Conferences::AdminLog::ConferenceUserRolePresenter
    end
  end
end
