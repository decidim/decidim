# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # Class that retrieves manageable initiatives for the given user.
      # Regular users will get only their initiatives. Administrators will
      # retrieve all initiatives.
      class ManageableInitiatives < Decidim::Query
        # Syntactic sugar to initialize the class and return the queried objects
        #
        # user - Decidim::User
        def self.for(user)
          new(user).query
        end

        # Initializes the class.
        #
        # user - Decidim::User
        def initialize(user)
          @user = user
        end

        # Retrieves all initiatives / Initiatives created by the user.
        def query
          return Initiative.where(organization: @user.organization) if @user.admin?

          Initiative.where(id: InitiativesCreated.by(@user) + InitiativesPromoted.by(@user))
        end
      end
    end
  end
end
