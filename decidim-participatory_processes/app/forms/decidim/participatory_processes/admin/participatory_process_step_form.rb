# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A form object used to create participatory processes steps from the admin
      # dashboard.
      #
      class ParticipatoryProcessStepForm < Form
        include TranslatableAttributes

        translatable_attribute :title, String
        translatable_attribute :description, String
        translatable_attribute :cta_text, String

        mimic :participatory_process_step

        attribute :start_date, Decidim::Attributes::TimeWithZone
        attribute :end_date, Decidim::Attributes::TimeWithZone
        attribute :cta_path, String

        validates :title, translatable_presence: true
        validates :cta_path, format: { with: %r{\A[a-zA-Z]+[a-zA-Z0-9\-_/]+\z} }, allow_blank: true

        validates :start_date, date: { before: :end_date, allow_blank: true, if: proc { |obj| obj.end_date.present? } }
        validates :end_date, date: { after: :start_date, allow_blank: true, if: proc { |obj| obj.start_date.present? } }
      end
    end
  end
end
