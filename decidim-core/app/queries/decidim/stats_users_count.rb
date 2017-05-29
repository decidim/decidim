# frozen_string_literal: true

module Decidim
  # This query counts registered users from a collection of organizations
  # in an optional interval of time.
  class StatsUsersCount < Rectify::Query
    def self.for(organization, start_at = nil, end_at = nil)
      new(organization, start_at, end_at).query
    end

    def initialize(organization, start_at = nil, end_at = nil)
      @organization = organization
      @start_at = start_at
      @end_at = end_at
    end

    def query
      users = Decidim::User.where(organization: @organization)
      users = users.where("created_at >= ?", @start_at) if @start_at.present?
      users = users.where("created_at <= ?", @end_at) if @end_at.present?
      users = users.where.not(confirmed_at: nil)
      users.count
    end
  end
end
