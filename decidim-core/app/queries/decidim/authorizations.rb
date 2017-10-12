# frozen_string_literal: true

module Decidim
  # Finds authorizations by different criteria
  class Authorizations < Rectify::Query
    # Initializes the class.
    #
    # @param name [String] The name of an authorization method
    # @param user [User] A user to find authorizations for
    def initialize(user: nil, name: nil)
      @user = user
      @name = name
    end

    # Finds the Authorizations for the given method
    #
    # Returns an ActiveRecord::Relation.
    def query
      scope = Authorization.where(nil)

      scope = scope.where(name: name) unless name.nil?
      scope = scope.where(user: user) unless user.nil?

      scope
    end

    private

    attr_reader :user, :name
  end
end
