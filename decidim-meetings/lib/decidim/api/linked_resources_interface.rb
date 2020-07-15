# frozen_string_literal: true

module Decidim
  module Meetings
    # This interface represents all linked resources available in the module meetings
    LinkedResourcesInterface = GraphQL::InterfaceType.define do
      name "MeetinsLinkedResourcewInterface"
      description "An interface that can be used with Resourceable models."

      field :proposalsFromMeeting, !types[Decidim::Proposals::ProposalType], "Proposals created in this meeting" do
        resolve ->(meeting, _args, _ctx) {
          meeting.linked_resources(:proposals, :proposals_from_meeting)
        }
      end
    end
  end
end
