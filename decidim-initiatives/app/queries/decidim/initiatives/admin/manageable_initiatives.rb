# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # Class that retrieves manageable initiatives for the given user.
      # Regular users will get only their initiatives. Administrators will
      # retrieve all initiatives.
      class ManageableInitiatives < Rectify::Query
        attr_reader :organization, :user, :q, :state

        # Syntactic sugar to initialize the class and return the queried objects
        #
        # organization - Decidim::Organization
        # user         - Decidim::User
        # query        - String
        # state        - String
        def self.for(organization, user, query, state)
          new(organization, user, query, state).query
        end

        # Initializes the class.
        #
        # organization - Decidim::Organization
        # user         - Decidim::User
        # query        - String
        # state        - String
        def initialize(organization, user, query, state)
          @organization = organization
          @user = user
          @q = query
          @state = state
        end

        # Retrieves all initiatives / Initiatives created by the user.
        def query
          if user.admin?
            base = Initiative
                   .where(organization: organization)
                   .with_state(state)
          else
            ids = InitiativesCreated.by(user).with_state(state).pluck(:id)
            ids += InitiativesPromoted.by(user).with_state(state).pluck(:id)
            base = Initiative.where(id: ids)
          end

          return base if q.blank?

          organization.available_locales.each_with_index do |loc, index|
            base = if index.zero?
                     base.where("title->>? ilike ?", loc, "#{q}%")
                         .or(Initiative.where("description->>? ilike ?", loc, "#{q}%"))
                   else
                     base
                       .or(Initiative.where("title->>? ilike ?", loc, "#{q}%"))
                       .or(Initiative.where("description->>? ilike ?", loc, "#{q}%"))
                   end
          end

          base
        end
      end
    end
  end
end
