# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # Form to create or update an election.
      class ElectionForm < Decidim::Form
        mimic :election

        include Decidim::HasUploadValidations
        include Decidim::AttachmentAttributes
        include Decidim::TranslatableAttributes

        translatable_attribute :title, String
        translatable_attribute :description, Decidim::Attributes::RichText

        attribute :start_time, DateTime
        attribute :end_time, DateTime
        attribute :manual_start, Boolean, default: true
        attribute :results_availability, :string, default: "after_end"
        attribute :attachment, AttachmentForm

        attachments_attribute :photos

        validates :title, presence: true
        validates :start_time, presence: true, unless: :manual_start?
        validates :end_time, presence: true, unless: :manual_start?
      end
    end
  end
end
