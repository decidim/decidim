# frozen_string_literal: true

module Decidim
  class AssemblyMemberAddedEvent < Decidim::ParticipatorySpace::MemberAddedEvent
    def members_page
      decidim_assemblies.assembly_members_url(participatory_space,
                                              host: participatory_space.organization.host)
    end
  end
end
