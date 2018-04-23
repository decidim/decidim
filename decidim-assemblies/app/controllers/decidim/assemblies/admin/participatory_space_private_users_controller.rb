# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # Controller that allows managing assembly private users
      # on assembies
      class ParticipatorySpacePrivateUsersController < Decidim::Admin::ApplicationController
        include Concerns::AssemblyAdmin
        include Decidim::Admin::Concerns::HasPrivateUsers

        def after_destroy_path
          participatory_space_private_users_path(current_assembly)
        end

        def privatable_to
          current_assembly
        end

        def authorization_object
          @participatory_space_private_user || ParticipatorySpacePrivateUser
        end

        def current_participatory_space_manifest_name
          :assemblies
        end
      end
    end
  end
end
