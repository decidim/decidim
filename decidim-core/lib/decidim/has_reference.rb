# frozen_string_literal: true
require "active_support/concern"

module Decidim
  # A concern with the features needed when you want a model to have a
  # reference.
  module HasReference
    extend ActiveSupport::Concern

    included do
      before_save :set_reference

      private

      def set_reference
        ref = current_organization.reference
        class_identifier = result.class.name.demodulize[0..3].upcase
        year_month = created_at.strftime("%Y-%m")

        reference = [ref, class_identifier, year_month, id].join("-")

        update_attribute(:reference, reference)
      end
    end
  end
end
