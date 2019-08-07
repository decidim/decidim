# frozen_string_literal: true

module Decidim
  # A Helper to render and link to partners for conferences.
  module Conferences
    module PartnersHelper
      # conference - The model to render the partners
      #
      # Returns nothing.
      def partners_for(conference)
        render partial: "partners", locals: { conference: conference }
      end
    end
  end
end
