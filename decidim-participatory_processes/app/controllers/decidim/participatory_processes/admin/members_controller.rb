# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows managing participatory process members
      class MembersController < Decidim::Admin::ApplicationController
        include Concerns::ParticipatoryProcessAdmin
        include Decidim::Admin::ParticipatorySpace::Concerns::HasMembers

        def after_destroy_path
          members_path(current_participatory_process)
        end

        def privatable_to
          current_participatory_process
        end
      end
    end
  end
end
