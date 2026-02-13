# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows importing participatory process members
      # on participatory processes
      class MembersCsvImportsController < Decidim::Admin::ApplicationController
        include Concerns::ParticipatoryProcessAdmin
        include Decidim::Admin::ParticipatorySpace::Concerns::HasMembersCsvImport

        def after_import_path
          members_path(current_participatory_process)
        end

        def participatory_space
          current_participatory_process
        end
      end
    end
  end
end
