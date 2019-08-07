# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # Helper for consultation controller
      module ConsultationsHelper
        def consultation_example_slug
          "consultation-#{Time.now.utc.year}-#{Time.now.utc.month}-1"
        end
      end
    end
  end
end
