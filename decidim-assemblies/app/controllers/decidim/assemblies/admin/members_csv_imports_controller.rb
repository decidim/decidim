# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # Controller that allows importing assembly private users
      # on assemblies
      class MembersCsvImportsController < Decidim::Admin::ApplicationController
        include Concerns::AssemblyAdmin
        include Decidim::Admin::Concerns::HasPrivateUsersCsvImport

        def after_import_path
          members_path(current_assembly)
        end

        def privatable_to
          current_assembly
        end
      end
    end
  end
end
