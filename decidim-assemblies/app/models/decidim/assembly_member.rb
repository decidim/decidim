# frozen_string_literal: true

module Decidim
  # It represents a member of the assembly (president, secretary, ...)
  # Can be linked to an existent user in the platform
  class AssemblyMember < ApplicationRecord
    include Decidim::Traceable

    GENDERS = %w(man woman).freeze
    POSITIONS = %w(president vice_president secretary other).freeze

    belongs_to :assembly, foreign_key: "decidim_assembly_id", class_name: "Decidim::Assembly"
  end
end
