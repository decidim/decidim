# frozen_string_literal: true

module Decidim
  module Assemblies
    # This type represents a assembly.
    class AssemblyMemberType < GraphQL::Schema::Object
      graphql_name "AssemblyMember"
      description "An assembly member"
      implements Decidim::Core::TimestampsInterface

      field :id, ID, null: false, description: "Internal ID of the member"
      field :fullName, String, null: true, description: "Full name of the member"
      field :position, String, null: true, description: "Position of the member in the assembly"
      field :user, Decidim::Core::UserType, null: true, description: "The corresponding decidim user"
      field :weight, Int, null: true, description: "Order of appearance in which it should be represented"
      field :gender, String, null: true, description: "Gender of the member"
      # field :birthday, Decidim::Core::DateType, "Birthday date of the member" # non-public currently
      field :birthplace, String, null: true, description: "Birthplace of the member"
      field :designationDate, Decidim::Core::DateType, null: true, description: "Date of designation of the member"
      # field :designationMode, types.String, "Mode in which the member was designated", property: :designation_mode # non-public currently
      field :positionOther, String, null: true, description: "Custom position name"
      field :ceasedDate, Decidim::Core::DateType, null: true, description: "Date of cease for the member"

      def fullName
        object.full_name
      end

      def designationDate
        object.designation_date
      end

      def positionOther
        object.position_other
      end

      def ceasedDate
        object.ceased_date
      end
    end
  end
end
