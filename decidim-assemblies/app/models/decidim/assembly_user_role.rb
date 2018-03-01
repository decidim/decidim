# frozen_string_literal: true

module Decidim
  # Defines a relation between a user and an assembly, and what kind of relation
  # does the user have.
  class AssemblyUserRole < ApplicationRecord
    include Traceable
    include Loggable

    belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User", optional: true
    belongs_to :assembly, foreign_key: "decidim_assembly_id", class_name: "Decidim::Assembly", optional: true
    alias participatory_space assembly

    ROLES = %w(admin collaborator moderator).freeze
    validates :role, inclusion: { in: ROLES }, uniqueness: { scope: [:user, :assembly] }
    validate :user_and_assembly_same_organization

    def self.log_presenter_class_for(_log)
      Decidim::Assemblies::AdminLog::AssemblyUserRolePresenter
    end

    private

    # Private: check if the process and the user have the same organization
    def user_and_assembly_same_organization
      return if !assembly || !user
      errors.add(:assembly, :invalid) unless user.organization == assembly.organization
    end
  end
end
