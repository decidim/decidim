# frozen_string_literal: true

module Decidim
  module Assemblies
    # This type represents a assembly.
    AssemblyMemberType = GraphQL::ObjectType.define do
      name "AssemblyMember"
      description "An assembly member"

      field :id, !types.ID, "Internal ID of the member"
      field :fullName, types.String, "Full name of the member", property: :full_name
      field :position, types.String, "Position of the member in the assembly"

      field :user, Decidim::Core::UserType, "The corresponding decidim user", property: :user

      field :createdAt, Decidim::Core::DateTimeType, "The time this member was created", property: :created_at
      field :updatedAt, Decidim::Core::DateTimeType, "The time this member was updated", property: :updated_at

      field :weight, types.Int, "Order of appearance in which it should be represented"
      field :gender, types.String, "Gender of the member"
      # field :birthday, Decidim::Core::DateType, "Birthday date of the member" # non-public currently
      field :birthplace, types.String, "Birthplace of the member"
      field :designationDate, Decidim::Core::DateType, "Date of designation of the member", property: :designation_date
      # field :designationMode, types.String, "Mode in which the member was designated", property: :designation_mode # non-public currently
      field :positionOther, types.String, "Custom position name", property: :position_other
      field :ceasedDate, Decidim::Core::DateType, "Date of cease for the member", property: :ceased_date
    end
  end
end
