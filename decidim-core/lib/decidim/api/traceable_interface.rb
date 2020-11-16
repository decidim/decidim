# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents an traceable object.
    #
    module TraceableInterface
      include GraphQL::Schema::Interface
      # name "TraceableInterface"
      description "An interface that can be used in objects with traceability (versions)"

      field :versionsCount, Int, null: false, description: "Total number of versions"
      field :versions, [Decidim::Core::TraceVersionType],  null: false, description: "This object's versions"


      def versionsCount
        object.versions_count
      end
    end
  end
end
