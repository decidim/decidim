# frozen-string_literal: true

module Decidim
  module Initiatives
    module Admin
      class InitiativeSentToTechnicalValidationEvent < Decidim::Events::SimpleEvent
        include Rails.application.routes.mounted_helpers

        i18n_attributes :admin_initiative_url, :admin_initiative_path

        def admin_initiative_path
          ResourceLocatorPresenter.new(resource).edit
        end

        def admin_initiative_url
          decidim_admin_initiatives.edit_initiative_url(resource, resource.mounted_params)
        end
      end
    end
  end
end
