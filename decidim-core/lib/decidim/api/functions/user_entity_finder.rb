# frozen_string_literal: true

module Decidim
  module Core
    # A resolver for the GraphQL user/group endpoints
    # Used in the keyword "user", ie:
    #
    # user(nickname: "foo") {
    #   name
    # }
    #
    class UserEntityFinder
      def call(_obj, args, ctx)
        filters = {
          organization: ctx[:current_organization]
        }
        args.each do |argument, value|
          next if value.blank?

          v = value.to_s
          v = v[1..-1] if value.starts_with? "@"
          filters[argument.to_sym] = v
        end
        Decidim::UserBaseEntity
          .where.not(confirmed_at: nil)
          .find_by(filters)
      end
    end
  end
end
