# frozen_string_literal: true

module Decidim
  module Demographics
    # DemographicsType = GraphQL::ObjectType.define do
    #   interfaces [-> { Decidim::Core::ComponentInterface }]
    #
    #   name "Demographics"
    #   description "A demographics component."
    #
    #   field :id, !types.ID, "ID of this demographic record"
    #   field :decidim_user_id, !types.ID, "ID of this user"
    #   field :gender, !types.String, property: :gender
    #   field :age, !types.String, property: :age
    #   field :nationalities, types[types.String], property: :nationalities
    #   field :other_nationalities, !types.String, property: :other_nationalities
    #   field :residences, types[types.String], property: :residences
    #   field :other_residences, !types.String, property: :other_residences
    #   field :living_condition, !types.String, property: :living_condition
    #   field :current_occupations, types[types.String], property: :current_occupations
    #   field :education_age_stop, !types.String, property: :education_age_stop
    #   field :attended_eu_event, !types.String, property: :attended_eu_event
    #   field :newsletter_subscribe, !types.String, property: :newsletter_subscribe
    #   field :other_ocupations, !types.String, property: :other_ocupations
    #   field :attended_before, !types.String, property: :attended_before
    #   field :newsletter_sign_in, !types.String, property: :newsletter_sign_in
    # end
  end
end
