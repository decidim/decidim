# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents an traceable object.
    TraceableInterface = GraphQL::InterfaceType.define do
      name "TraceableInterface"
      description "An interface that can be used in objects with traceability (versions)"

      field :versionsCount, !types.Int, "Total number of versions", property: :versions_count
      field :versions, !types[Decidim::Core::TraceVersionType], "This object's versions"
    end
  end
end
