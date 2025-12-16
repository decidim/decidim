# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # Controller that allows managing assembly members
      # on assemblies
      class MembersController < Decidim::Assemblies::Admin::ApplicationController
        include Concerns::AssemblyAdmin
        include Decidim::Admin::ParticipatorySpace::Concerns::HasMembers

        def after_destroy_path
          members_path(current_assembly)
        end

        def participatory_space
          current_assembly
        end
      end
    end
  end
end
