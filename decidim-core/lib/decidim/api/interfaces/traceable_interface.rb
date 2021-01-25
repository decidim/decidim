# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents an traceable object.
    module TraceableInterface
      include Decidim::Api::Types::BaseInterface
      description "An interface that can be used in objects with traceability (versions)"

      field :versions_count, Integer, "Total number of versions", null: false
      field :versions, [Decidim::Core::TraceVersionType, { null: true }], "This object's versions", null: false
    end
  end
end
