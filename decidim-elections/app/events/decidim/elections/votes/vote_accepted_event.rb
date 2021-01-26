# frozen-string_literal: true

module Decidim
  module Elections
    module Votes
      class VoteAcceptedEvent < Decidim::Events::SimpleEvent
        # This event sends a notification with the vote hash and further instructions
        i18n_attributes :resource_name, :encrypted_vote_hash, :verify_url

        def resource_name
          @resource_name ||= translated_attribute(resource.title)
        end

        def encrypted_vote_hash
          extra[:vote]["encrypted_vote_hash"]
        end

        def verify_url
          Decidim::EngineRouter.main_proxy(resource.component).verify_election_vote_url(resource)
        end
      end
    end
  end
end
