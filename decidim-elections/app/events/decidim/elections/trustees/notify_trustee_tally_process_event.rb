# frozen_string_literal: true

module Decidim
  module Elections
    module Trustees
      class NotifyTrusteeTallyProcessEvent < Decidim::Events::SimpleEvent
        # This event sends a notification when an an admin started the tally process.
        def resource_name
          @resource_name ||= translated_attribute(election.title)
        end
      end
    end
  end
end
