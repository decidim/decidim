# frozen_string_literal: true

module Decidim
  # A Helper to render and link to partners for conferences.
  module Conferences
    module PartnersHelper
      # conference - The model to render the partners
      #
      # Returns nothing.

      # deprecated
      def partners_for(conference)
        render partial: "partners", locals: { conference: }
      end
    end
  end
end
