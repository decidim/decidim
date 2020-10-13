# frozen_string_literal: true

module Decidim
  module Demographics
    DemographicsType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Core::ComponentInterface }]

      name "Demographics"
      description "A demographics component."

      field :id, !types.ID
    end
  end
end
