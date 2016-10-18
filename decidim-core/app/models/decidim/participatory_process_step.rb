# frozen_string_literal: true
module Decidim
  # A ParticipatoryProcess is composed of many steps that hold different
  # features that will show up in the depending on what step is currently
  # active.
  class ParticipatoryProcessStep < ApplicationRecord
    belongs_to :participatory_process, foreign_key: "decidim_participatory_process_id", class_name: Decidim::ParticipatoryProcess
    delegate :organization, to: :participatory_process
  end
end
