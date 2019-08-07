# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # A form object used to create responses for a question from the admin dashboard.
      class ResponseForm < Form
        include TranslatableAttributes

        mimic :response

        translatable_attribute :title, String

        validates :title, translatable_presence: true
      end
    end
  end
end
