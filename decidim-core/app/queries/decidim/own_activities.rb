# frozen_string_literal: true

module Decidim
  class OwnActivities < PublicActivities
    def query
      query = ActionLog
              .where(visibility: %w(private-only public-only all))
              .where(organization: organization)

      query = query.where(user: user) if user
      query = query.where(resource_type: resource_name) if resource_name.present?

      query = filter_follows(query)
      query = filter_hidden(query)

      query.order(created_at: :desc)
    end
  end
end
