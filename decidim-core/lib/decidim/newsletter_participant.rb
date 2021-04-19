# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # This concern contains the logic related to newsletter participants
  module NewsletterParticipant
    extend ActiveSupport::Concern

    included do
      # Returns a User collection Participants
      # Behaves as an abstract method, you must overwrite it in each includer class.
      def self.newsletter_participant_ids(_component); end
    end
  end
end
