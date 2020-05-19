# frozen-string_literal: true

module Decidim
  module Elections
    # Notifies users about a new election.
    class CreateElectionEvent < Decidim::Events::SimpleEvent
      def resource_text
        translated_attribute(resource.description)
      end
    end
  end
end
