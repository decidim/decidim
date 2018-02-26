# frozen_string_literal: true

module Decidim
  class AssemblyParticipatoryProcess < ApplicationRecord
    belongs_to :assembly, foreign_key: "decidim_assembly_id", class_name: "Decidim::Assembly"
    belongs_to :participatory_process, foreign_key: "decidim_participatory_process_id", class_name: "Decidim::ParticipatoryProcess"
  end
end
