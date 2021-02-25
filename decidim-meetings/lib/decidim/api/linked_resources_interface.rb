# frozen_string_literal: true

module Decidim
  module Meetings
    # This interface represents all linked resources available in the module meetings
    module LinkedResourcesInterface
      include Decidim::Api::Types::BaseInterface
      graphql_name "MeetinsLinkedResourcewInterface"
      description "An interface that can be used with Resourceable models."

      field :proposals_from_meeting, [Decidim::Proposals::ProposalType, { null: true }], "Proposals created in this meeting", null: false

      def proposals_from_meeting
        object.linked_resources(:proposals, :proposals_from_meeting)
      end
    end
  end
end
