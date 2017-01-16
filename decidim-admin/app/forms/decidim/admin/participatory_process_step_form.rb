# frozen_string_literal: true
module Decidim
  module Admin
    # A form object used to create participatory processes steps from the admin
    # dashboard.
    #
    class ParticipatoryProcessStepForm < Form
      include TranslatableAttributes

      translatable_attribute :title, String
      translatable_attribute :description, String
      translatable_attribute :short_description, String

      mimic :participatory_process_step

      attribute :start_date, DateTime
      attribute :end_date, DateTime

      validates :title, translatable_presence: true

      validates :start_date, date: { before: :end_date, allow_blank: true, if: proc { |obj| obj.end_date.present? } }
      validates :end_date, date: { after: :start_date, allow_blank: true, if: proc { |obj| obj.start_date.present? } }

      def start_date
        return nil unless super.respond_to?(:at_midnight)
        super.at_midnight
      end

      def end_date
        return nil unless super.respond_to?(:at_midnight)
        super.at_midnight
      end
    end
  end
end
