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

        attribute :start_at, DateTime
        attribute :end_at, DateTime
        attribute :manual_start, Boolean, default: true
        attribute :results_availability, :string, default: "real_time"
        attribute :attachment, AttachmentForm

        attachments_attribute :photos

        validates :title, translatable_presence: true
        validates :description, translatable_presence: true
        validates :start_at, presence: true, unless: :manual_start?
        validates :end_at, presence: true, unless: :manual_start?
      end
    end
  end
end
