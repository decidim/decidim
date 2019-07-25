# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Consultations
    module Admin
      # This concern is meant to be included in all controllers that are scoped
      # into an consultation's admin panel. It will override the layout so it shows
      # the sidebar, preload the consultation, etc.
      module ConsultationAdmin
        extend ActiveSupport::Concern

        RegistersPermissions
          .register_permissions(::Decidim::Consultations::Admin::ConsultationAdmin,
                                ::Decidim::Consultations::Permissions,
                                ::Decidim::Admin::Permissions)

        included do
          include NeedsConsultation

          layout "decidim/admin/consultation"

          alias_method :current_participatory_space, :current_consultation

          def permission_class_chain
            PermissionsRegistry.chain_for(ConsultationAdmin)
          end
        end
      end
    end
  end
end
