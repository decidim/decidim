# frozen_string_literal: true

module Decidim
  # Defines a relation between a user and an assembly, and what kind of relation
  # does the user have.
  class AssemblyUserRole < ApplicationRecord
    include Traceable
    include Loggable
    include ParticipatorySpaceUser

    belongs_to :assembly, foreign_key: "decidim_assembly_id", class_name: "Decidim::Assembly", optional: true
    alias participatory_space assembly

    scope :for_space, ->(participatory_space) { where(assembly: participatory_space) }

    validates :role, inclusion: { in: ParticipatorySpaceUser::ROLES }, uniqueness: { scope: [:user, :assembly] }
    def target_space_association = :assembly

    def self.log_presenter_class_for(_log)
      Decidim::Assemblies::AdminLog::AssemblyUserRolePresenter
    end
  end
end
