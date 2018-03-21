# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # This controller allows admins to manage moderations in a participatory process.
      class ModerationsController < Decidim::Admin::ModerationsController
        include Concerns::ParticipatoryProcessAdmin
        include NeedsPermission

        def permission_scope
          :admin
        end

        def permission_klass
          Decidim::ParticipatoryProcesses::Permissions
        end

        # Overrides the method to use the permissions system logic.
        def ensure_access_to(action, _subject = reportable)
          check_permission_to action, :moderation
        end
      end
    end
  end
end
