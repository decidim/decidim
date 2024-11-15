# frozen_string_literal: true

module Decidim
  module Admin
    # Custom helpers, scoped to the admin panel.
    #
    module ApplicationHelper
      include Decidim::LocalizedLocalesHelper
      include Decidim::TranslationsHelper
      include Decidim::HumanizeBooleansHelper
      include Decidim::AriaSelectedLinkToHelper
      include Decidim::MetaTagsHelper
      include Decidim::MapHelper
      include Decidim::Admin::LogRenderHelper
      include Decidim::Admin::UserRolesHelper
      include Decidim::Admin::SearchFormHelper

      # Public: Overwrites the `cell` helper method to automatically set some
      # common context.
      #
      # name - the name of the cell to render
      # model - the cell model
      # options - a Hash with options
      #
      # Renders the cell contents.
      def cell(name, model, options = {}, &)
        options = { context: { view_context: self, current_user: } }.deep_merge(options)
        super
      end

      def participatory_space_active_link?(component)
        endpoints = component.manifest.admin_engine.try(:participatory_space_endpoints)
        endpoints && is_active_link?(decidim_admin_participatory_processes.components_path(current_participatory_space), %r{/\d+/manage/(#{endpoints.join("|")})\b})
      end
    end
  end
end
