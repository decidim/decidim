# frozen_string_literal: true

module Decidim
  class UserActivityCell < Decidim::ViewModel
    include Cell::ViewModel::Partial
    include CellsPaginateHelper
    include Decidim::Core::Engine.routes.url_helpers

    def show
      render :show
    end

    def activities
      resource_ids_to_filter = context[:activities].select { |log| log[:action] == "delete" && log[:resource_type] == "Decidim::Comments::Comment" }.map(&:resource_id)
      if resource_ids_to_filter.any?
        context[:activities].where.not("resource_id in (?) AND resource_type = ?", resource_ids_to_filter, "Decidim::Comments::Comment")
      else
        context[:activities]
      end
    end

    def resource_types
      context[:resource_types]
    end

    def filter
      context[:filter]
    end
  end
end
