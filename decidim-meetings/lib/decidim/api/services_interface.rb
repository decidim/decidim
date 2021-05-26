# frozen_string_literal: true

module Decidim
  module Meetings
    # This interface represents a categorizable object.
    module ServicesInterface
      include Decidim::Api::Types::BaseInterface
      description "An interface that can be used with services."

      field :services, [Decidim::Meetings::ServiceType, { null: true }], "The object's services", null: false
    end
  end
end
