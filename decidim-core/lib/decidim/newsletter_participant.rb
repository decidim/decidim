# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # This concern contains the logic related to data portability.
  module NewsletterParticipant
    extend ActiveSupport::Concern

    included do
      # Returns a User collection Participants
      # This is the default, if you want, you can overwrite in each Class to be export.
      def self.newsletter_participant_ids(_component)
        nil
      end
      #
      # # Returns a Default export serializer
      # def self.export_serializer
      #   Decidim::Exporters::Serializer
      # end
      #
      # # Returns a collection of images scoped by User.
      # # Returns nil for default.
      # def self.data_portability_images(_user)
      #   nil
      # end
    end
  end
end
