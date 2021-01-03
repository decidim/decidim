# frozen-string_literal: true

module Decidim
  module Elections
    module Trustees
      class NotifyTrusteeNewElectionEvent < Decidim::Events::SimpleEvent
        # This event sends a notification when a new trustee gets an election.
        def resource_name
          @resource_name ||= translated_attribute(election.title)
        end
      end
    end
  end
end
