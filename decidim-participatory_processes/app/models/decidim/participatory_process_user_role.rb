# frozen_string_literal: true

module Decidim
  # Defines a relation between a user and a participatory process, and what
  # kind of relation does the user has.
  class ParticipatoryProcessUserRole < ApplicationRecord
    include Traceable
    include Loggable
    include ParticipatorySpaceUser

    belongs_to :participatory_process, foreign_key: "decidim_participatory_process_id", class_name: "Decidim::ParticipatoryProcess", optional: true
    alias participatory_space participatory_process

    scope :for_space, ->(participatory_space) { where(participatory_process: participatory_space) }

    validates :role, inclusion: { in: ParticipatorySpaceUser::ROLES }, uniqueness: { scope: [:user, :participatory_process] }
    def target_space_association = :participatory_process

    def self.log_presenter_class_for(_log)
      Decidim::ParticipatoryProcesses::AdminLog::ParticipatoryProcessUserRolePresenter
    end
  end
end
