# frozen-string_literal: true

module Decidim
  module Initiatives
    class InitiativeSentToTechnicalValidationEvent < Decidim::Events::SimpleEvent
      include Rails.application.routes.mounted_helpers

      i18n_attributes :admin_initiative_url, :admin_initiative_path

      def admin_initiative_path
        ResourceLocatorPresenter.new(resource).edit
      end

      def admin_initiative_url
        EngineRouter.admin_proxy(resource).edit_initiative_url(resource)
      end
    end
  end
end
