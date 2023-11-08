# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # Controller that allows managing all the attachments for a participatory
      # assembly.
      #
      class AssemblyAttachmentsController < Decidim::Assemblies::Admin::ApplicationController
        include Concerns::AssemblyAdmin
        include Decidim::Admin::Concerns::HasAttachments
        include Decidim::Admin::Concerns::HasTabbedMenu

        def after_destroy_path
          assembly_attachments_path(current_assembly)
        end

        def attached_to
          current_assembly
        end

        private

        def tab_menu_name = :assemblies_admin_attachments_menu
      end
    end
  end
end
