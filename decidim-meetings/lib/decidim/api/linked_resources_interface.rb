# frozen_string_literal: true

module Decidim
  module Meetings
    # This interface represents all linked resources available in the module meetings

    module LinkedResourcesInterface
      include GraphQL::Schema::Interface
      # name "MeetinsLinkedResourcewInterface"
      description "An interface that can be used with Resourceable models."

      field :proposalsFromMeeting, [Decidim::Proposals::ProposalType], null: false, description: "Proposals created in this meeting" do
        def resolve(meeting:, _args:, _ctx:)
          meeting.linked_resources(:proposals, :proposals_from_meeting)
        end
      end
    end
  end
end
