# frozen_string_literal: true

module Decidim
  module Demographics
    DemographicsType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Core::ComponentInterface }]

      name "Demographics"
      description "A demographics component."
      # In order to be GDPR compliant the id fields are commented
      # field :id, !types.ID, "ID of this demographic record"
      # field :decidim_user_id, !types.ID, "ID of this user"
      field :age, !types.String, property: :age
      field :gender, !types.String, property: :gender
      field :nationality, !types.String, property: :nationality
      field :background, !types.String, property: :background
      field :postal_code, !types.String, property: :postal_code
    end
  end
end
