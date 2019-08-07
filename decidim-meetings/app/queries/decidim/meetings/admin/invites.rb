# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # A class used to find the Invites by their status status.
      class Invites < Rectify::Query
        # Syntactic sugar to initialize the class and return the queried objects.
        #
        # invites - the initial Invites relation that needs to be filtered.
        # query - query to filter invites
        # status - invite status to be used as a filter
        def self.for(invites, query = nil, status = nil)
          new(invites, query, status).query
        end

        # Initializes the class.
        #
        # invites - the initial Invites relation that need to be filtered
        # query - query to filter invites
        # status - invite status to be used as a filter
        def initialize(invites, query = nil, status = nil)
          @invites = invites
          @query = query
          @status = status
        end

        # List the invites by the different filters.
        def query
          @invites = filter_by_search(@invites)
          @invites = filter_by_status(@invites)
          @invites
        end

        private

        def filter_by_search(invites)
          return invites if @query.blank?

          invites.joins(:user).where(
            User.arel_table[:name].lower.matches("%#{@query}%").or(User.arel_table[:email].lower.matches("%#{@query}%"))
          )
        end

        def filter_by_status(invites)
          case @status
          when "accepted"
            invites.where.not(accepted_at: nil)
          when "rejected"
            invites.where.not(rejected_at: nil)
          when "sent"
            invites.where.not(sent_at: nil).where(accepted_at: nil, rejected_at: nil)
          else
            invites
          end
        end
      end
    end
  end
end
