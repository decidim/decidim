# frozen_string_literal: true
module Decidim
  # A ParticipatoryProcess is composed of many steps that hold different
  # features that will show up in the depending on what step is currently
  # active.
  class ParticipatoryProcessStep < ApplicationRecord
    belongs_to :participatory_process, foreign_key: "decidim_participatory_process_id", class_name: Decidim::ParticipatoryProcess
    has_one :organization, through: :participatory_process

    validates :start_date, date: { before: :end_date, allow_blank: true, if: proc { |obj| obj.end_date.present? } }
    validates :end_date, date: { after: :start_date, allow_blank: true, if: proc { |obj| obj.start_date.present? } }
  end
end
