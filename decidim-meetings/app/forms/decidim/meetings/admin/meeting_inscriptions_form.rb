# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This class holds a Form to update meeting inscriptions from Decidim's admin panel.
      class MeetingInscriptionsForm < Decidim::Form
        include TranslatableAttributes

        mimic :meeting

        attribute :inscriptions_enabled, Boolean
        attribute :available_slots, Integer
        translatable_attribute :inscription_terms, String
      end
    end
  end
end
