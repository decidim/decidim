# frozen_string_literal: true

module Decidim
  class AssemblyParticipatoryProcess < ApplicationRecord
    belongs_to :assembly, foreign_key: "decidim_assembly_id", class_name: "Decidim::Assembly"
    belongs_to :participatory_process, foreign_key: "decidim_participatory_process_id", class_name: "Decidim::ParticipatoryProcess"

    validates :participatory_process, uniqueness: { scope: :assembly }
    validate :assembly_and_participatory_process_same_organization

    private

    # Private: check if the process and the user have the same organization
    def assembly_and_participatory_process_same_organization
      return if !assembly || !participatory_process
      errors.add(:participatory_process, :invalid) unless assembly.organization == participatory_process.organization
    end
  end
end
