# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # A form object used to create responses for a question from the admin dashboard.
      class ResponseGroupForm < Form
        include TranslatableAttributes

        mimic :response_group

        translatable_attribute :title, String

        validates :title, translatable_presence: true
      end
    end
  end
end
