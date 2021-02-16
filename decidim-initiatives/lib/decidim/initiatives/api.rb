# frozen_string_literal: true

module Decidim
  module Initiatives
    autoload :InitiativeTypeInterface, "decidim/api/initiative_type_interface"
    autoload :InitiativeType, "decidim/api/initiative_type"
    autoload :InitiativeApiType, "decidim/api/initiative_api_type"
    autoload :InitiativeCommitteeMemberType, "decidim/api/initiative_committee_member_type"
  end
end
