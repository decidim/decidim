# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A class used to find the AssemblyMembers's by their status status.
      class AssemblyMembers < Decidim::Query
        # Syntactic sugar to initialize the class and return the queried objects.
        #
        # assembly_members - the initial AssemblyMember relation that needs to be filtered.
        # query - query to filter user group names
        # status - ceased status to be used as a filter
        def self.for(assembly_members, query = nil, status = nil)
          new(assembly_members, query, status).query
        end

        # Initializes the class.
        #
        # assembly_members - the AssemblyMember relation that need to be filtered
        # query - query to filter user group names
        # status - ceased status to be used as a filter
        def initialize(assembly_members, query = nil, status = nil)
          @assembly_members = assembly_members
          @query = query
          @status = status
        end

        # List the assembly members by the different filters.
        def query
          @assembly_members = filter_by_search(@assembly_members)
          @assembly_members = filter_by_status(@assembly_members)
          @assembly_members
        end

        private

        def filter_by_search(assembly_members)
          return assembly_members if @query.blank?

          assembly_members.where("LOWER(full_name) LIKE LOWER(?)", "%#{@query}%")
        end

        def filter_by_status(assembly_members)
          case @status
          when "ceased"
            assembly_members.where.not(ceased_date: nil)
          when "not_ceased"
            assembly_members.where(ceased_date: nil)
          else
            assembly_members
          end
        end
      end
    end
  end
end
