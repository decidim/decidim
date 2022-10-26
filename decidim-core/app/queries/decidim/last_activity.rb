# frozen_string_literal: true

module Decidim
  # This query finds the public ActionLog entries that can be shown in the
  # activities views of the application within a Decidim Organization. It is
  # intended to be used in the "Last activities" content block in the homepage,
  # and also in the "Last activities" page, to retrieve public activity of this
  # organization.
  class LastActivity < Decidim::Query
    def initialize(organization)
      @organization = organization
    end

    def query
      ActionLog
        .where(
          organization: @organization,
          visibility: %w(public-only all)
        )
        .with_new_resource_type("all")
        .order(created_at: :desc)
    end
  end
end
