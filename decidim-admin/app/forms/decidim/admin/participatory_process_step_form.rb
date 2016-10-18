# frozen_string_literal: true
module Decidim
  module Admin
    # A form object used to create participatory processes steps from the admin
    # dashboard.
    #
    class ParticipatoryProcessStepForm < Rectify::Form
      include TranslatableAttributes

      translatable_attribute :title, String
      translatable_attribute :description, String
      translatable_attribute :short_description, String

      mimic :participatory_process_step

      attribute :start_date, DateTime
      attribute :end_date, DateTime

      translatable_validates :title, :description, :short_description, presence: true
    end
  end
end
