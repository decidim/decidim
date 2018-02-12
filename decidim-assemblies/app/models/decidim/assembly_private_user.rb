# frozen_string_literal: true

module Decidim
  # This class gives a given User access to a given private Assembly
  class AssemblyPrivateUser < ApplicationRecord
    belongs_to :user, class_name: "Decidim::User", foreign_key: :decidim_user_id, optional: true
    belongs_to :assembly, class_name: "Decidim::Assembly", foreign_key: :decidim_assembly_id, optional: true

    validate :user_and_assembly_same_organization

    private

    # Private: check if the process and the user have the same organization
    def user_and_assembly_same_organization
      return if !assembly || !user
      errors.add(:assembly, :invalid) unless user.organization == assembly.organization
    end
  end
end
