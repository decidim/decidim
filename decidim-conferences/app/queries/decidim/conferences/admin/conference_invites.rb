# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A class used to find the ConferenceInvites by their status status.
      class ConferenceInvites < Decidim::Query
        # Syntactic sugar to initialize the class and return the queried objects.
        #
        # conference_invites - the initial Invites relation that needs to be filtered.
        # query - query to filter conference_invites
        # status - invite status to be used as a filter
        def self.for(conference_invites, query = nil, status = nil)
          new(conference_invites, query, status).query
        end

        # Initializes the class.
        #
        # conference_invites - the initial Invites relation that need to be filtered
        # query - query to filter conference_invites
        # status - invite status to be used as a filter
        def initialize(conference_invites, query = nil, status = nil)
          @conference_invites = conference_invites
          @query = query
          @status = status
        end

        # List the conference_invites by the different filters.
        def query
          @conference_invites = filter_by_search(@conference_invites)
          @conference_invites = filter_by_status(@conference_invites)
          @conference_invites
        end

        private

        def filter_by_search(conference_invites)
          return conference_invites if @query.blank?

          conference_invites.joins(:user).where(
            User.arel_table[:name].lower.matches("%#{@query}%").or(User.arel_table[:email].lower.matches("%#{@query}%"))
          )
        end

        def filter_by_status(conference_invites)
          case @status
          when "accepted"
            conference_invites.where.not(accepted_at: nil)
          when "rejected"
            conference_invites.where.not(rejected_at: nil)
          when "sent"
            conference_invites.where.not(sent_at: nil).where(accepted_at: nil, rejected_at: nil)
          else
            conference_invites
          end
        end
      end
    end
  end
end
