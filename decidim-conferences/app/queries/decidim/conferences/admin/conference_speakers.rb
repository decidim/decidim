# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A class used to find the ConferenceSpeakers's by the search.
      class ConferenceSpeakers < Decidim::Query
        # Syntactic sugar to initialize the class and return the queried objects.
        #
        # conference_speakers - the initial ConferenceSpeaker relation that needs to be filtered.
        # query - query to filter user names
        def self.for(conference_speakers, query = nil)
          new(conference_speakers, query).query
        end

        # Initializes the class.
        #
        # conference_speakers - the ConferenceSpeaker relation that need to be filtered
        # query - query to filter user names
        def initialize(conference_speakers, query = nil)
          @conference_speakers = conference_speakers
          @query = query
        end

        # List the conference speakers by the different filters.
        def query
          @conference_speakers = filter_by_search(@conference_speakers)
          @conference_speakers
        end

        private

        def filter_by_search(conference_speakers)
          return conference_speakers if @query.blank?

          conference_speakers.where("LOWER(full_name) LIKE LOWER(?)", "%#{@query}%")
        end
      end
    end
  end
end
