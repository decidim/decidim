# frozen_string_literal: true

module Decidim
  # This query counts registered users from a collection of organizations
  # in an optional interval of time.
  class AuthorizedUsers < Decidim::Query
    def initialize(organization:, handlers: [])
      @organization = organization
      @valid_types = organization.available_authorizations
      @handlers = handlers&.select { |type| @valid_types.include?(type) } || []
      @users = organization.users.not_deleted.not_blocked.confirmed
    end

    def query
      return @users if @handlers.blank?

      verified_users = Decidim::Authorization.select(:decidim_user_id)
                                             .where(decidim_user_id: @users.select(:id))
                                             .where.not(granted_at: nil)
                                             .where(name: @handlers)
                                             .group(:decidim_user_id)
                                             .having("COUNT(distinct name) = ?", @handlers.count)
      @users = @users.where(id: verified_users)
    end
  end
end
