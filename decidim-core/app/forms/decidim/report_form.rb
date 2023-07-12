# frozen_string_literal: true

module Decidim
  # A form object to be used when public users want to report a reportable.
  class ReportForm < Decidim::Form
    mimic :report

    attribute :reason, String
    attribute :details, String
    attribute :hide, Boolean, default: false
    attribute :block, Boolean, default: false

    validates :reason, inclusion: { in: Report::REASONS }
  end
end
