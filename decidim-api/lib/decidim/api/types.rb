# frozen_string_literal: true

module Decidim
  module Api
    autoload :QueryType, "decidim/api/query_type"
    autoload :MutationType, "decidim/api/mutation_type"
    autoload :ParticipantDetailsType, "decidim/api/participant_details_type"
    autoload :Schema, "decidim/api/schema"
    autoload :RequiredScopes, "decidim/api/required_scopes"

    module Types
      autoload :BaseArgument, "decidim/api/types/base_argument"
      autoload :BaseEnum, "decidim/api/types/base_enum"
      autoload :BaseField, "decidim/api/types/base_field"
      autoload :BaseInputObject, "decidim/api/types/base_input_object"
      autoload :BaseInterface, "decidim/api/types/base_interface"
      autoload :BaseMutation, "decidim/api/types/base_mutation"
      autoload :BaseObject, "decidim/api/types/base_object"
      autoload :BaseScalar, "decidim/api/types/base_scalar"
      autoload :BaseUnion, "decidim/api/types/base_union"
    end
  end
end
