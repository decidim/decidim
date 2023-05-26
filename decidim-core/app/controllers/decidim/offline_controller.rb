# frozen_string_literal: true

module Decidim
  class OfflineController < Decidim::ApplicationController
    include HasSpecificBreadcrumb

    def show; end

    def breadcrumb_item
      {
        label: t("decidim.offline.name"),
        active: true
      }
    end
  end
end
