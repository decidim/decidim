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

    validates :active, uniqueness: { scope: :decidim_participatory_process_id }, if: proc { |step| step.active? }

    validates :position, numericality: { greater_than_or_equal_to: 0, only_integer: true }, allow_blank: true

    before_create :set_position

    private

    # Internal: Sets the position of the step if it is `nil`. That means that
    # when the step is the first of the process, and no position is set
    # manually, it will be set to 0, and when it is not the only one it will be
    # set to the last step's position + 1.
    #
    # Note: This allows manual positioning, so it can cause different steps to
    # have the same position.
    def set_position
      return if position.present?
      return self.position = 0 if participatory_process.steps.empty?

      self.position = participatory_process.steps.last.position + 1
    end
  end
end
