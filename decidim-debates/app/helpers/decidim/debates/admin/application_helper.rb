# frozen_string_literal: true

module Decidim
  module Debates
    module Admin
      # Custom helpers, scoped to the debates admin engine.
      #
      module ApplicationHelper
        include Decidim::Admin::ResourceScopeHelper

        def link_to_filtered_debates
          unfiltered = params[:filter].blank?
          link_to(
            t("actions.#{unfiltered ? "archived" : "active"}", scope: "decidim.debates", name: t("models.debate.name", scope: "decidim.debates.admin")),
            debates_path(unfiltered ? { filter: "archive" } : {}),
            class: "button tiny button--simple"
          )
        end
      end
    end
  end
end
