# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # A form object used to create responses for a question from the admin dashboard.
      class ResponseForm < Form
        include TranslatableAttributes

        mimic :response

        translatable_attribute :title, String
        attribute :decidim_consultations_response_group_id, Integer

        validates :title, translatable_presence: true

        def response_group
          ResponseGroup.find_by(id: decidim_consultations_response_group_id) if decidim_consultations_response_group_id
        end
      end
    end
  end
end
