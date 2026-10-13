# frozen_string_literal: true

module Decidim
  class OfflineController < Decidim::ApplicationController
    include HasSpecificBreadcrumb

    def show
      enforce_permission_to :read, :offline
    end

    private

    def breadcrumb_item
      {
        label: t("decidim.offline.name"),
        active: true
      }
    end
  end
end
