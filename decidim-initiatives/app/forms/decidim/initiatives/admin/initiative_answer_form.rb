# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # A form object used to manage the initiative answer in the
      # administration panel.
      class InitiativeAnswerForm < Form
        include TranslatableAttributes

        mimic :initiative

        translatable_attribute :answer, String
        attribute :answer_url, String
        attribute :signature_start_date, Decidim::Attributes::LocalizedDate
        attribute :signature_end_date, Decidim::Attributes::LocalizedDate

        validates :signature_start_date, :signature_end_date, presence: true, if: :signature_dates_required?
        validates :signature_end_date, date: { after: :signature_start_date }, if: lambda { |form|
          form.signature_start_date.present? && form.signature_end_date.present?
        }

        def signature_dates_required?
          @signature_dates_required ||= context.initiative.state == "published"
        end
      end
    end
  end
end
