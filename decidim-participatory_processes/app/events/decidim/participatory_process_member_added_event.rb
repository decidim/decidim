# frozen_string_literal: true

module Decidim
  class ParticipatoryProcessMemberAddedEvent < Decidim::ParticipatorySpace::MemberAddedEvent
    def members_page
      decidim_participatory_processes.participatory_process_members_url(participatory_space,
                                                                        host: participatory_space.organization.host)
    end
  end
end
