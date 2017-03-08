# frozen_string_literal: true
module Decidim
  # A moderation belongs to a reportable and includes many reports
  class Moderation < ApplicationRecord
    belongs_to :reportable, foreign_key: "decidim_reportable_id", foreign_type: "decidim_reportable_type", polymorphic: true
    belongs_to :participatory_process, foreign_key: "decidim_participatory_process_id", class_name: Decidim::ParticipatoryProcess
    has_many :reports, foreign_key: "decidim_moderation_id", class_name: "Decidim::Report"

    validates :reportable, presence: true

    delegate :feature, :organization, to: :reportable
  end
end
