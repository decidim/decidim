# frozen_string_literal: true

module Decidim
  module Assemblies
    # This type represents a assembly.
    class AssemblyMemberType < Decidim::Api::Types::BaseObject
      description "An assembly member"

      field :id, GraphQL::Types::ID, "Internal ID of the member", null: false
      field :full_name, GraphQL::Types::String, "Full name of the member", null: true
      field :position, GraphQL::Types::String, "Position of the member in the assembly", null: true

      field :user, Decidim::Core::UserType, "The corresponding decidim user", null: true

      field :created_at, Decidim::Core::DateTimeType, "The time this member was created", null: true
      field :updated_at, Decidim::Core::DateTimeType, "The time this member was updated", null: true

      field :weight, GraphQL::Types::Int, "Order of appearance in which it should be represented", null: true
      field :gender, GraphQL::Types::String, "Gender of the member", null: true
      # field :birthday, Decidim::Core::DateType, "Birthday date of the member" # non-public currently
      field :birthplace, GraphQL::Types::String, "Birthplace of the member", null: true
      field :designation_date, Decidim::Core::DateType, "Date of designation of the member", null: true
      field :position_other, GraphQL::Types::String, "Custom position name", null: true
      field :ceased_date, Decidim::Core::DateType, "Date of cease for the member", null: true
    end
  end
end
