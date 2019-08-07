# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # This concern contains the logic related to newsletter participants
  module NewsletterParticipant
    extend ActiveSupport::Concern

    included do
      # Returns a User collection Participants
      # This is the default, if you want, you can overwrite in each Class to be export.
      def self.newsletter_participant_ids(_component)
        nil
      end
    end
  end
end
