# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A class used to find the admins for an assembly or an organization assemblies.
      class AdminUsers < Decidim::Query
        # Syntactic sugar to initialize the class and return the queried objects.
        #
        # assembly - an assembly that needs to find its assembly admins
        def self.for(assembly)
          new(assembly).query
        end

        # Syntactic sugar to initialize the class and return the queried objects.
        #
        # organization - an organization that needs to find its assembly admins
        def self.for_organization(organization)
          new(nil, organization).query
        end

        # Initializes the class.
        #
        # assembly - an assembly that needs to find its assembly admins
        # organization - an organization that needs to find its assembly admins
        def initialize(assembly, organization = nil)
          @assembly = assembly
          @organization = assembly&.organization || organization
        end

        # Finds organization admins and the users with role admin for the given assembly.
        #
        # Returns an ActiveRecord::Relation.
        def query
          organization.admins.or(assemblies_user_admins)
        end

        private

        attr_reader :assembly, :organization

        def assemblies_user_admins
          Decidim::User.where(
            id: Decidim::AssemblyUserRole.where(assembly: assemblies, role: :admin)
                                         .select(:decidim_user_id)
          )
        end

        def assemblies
          if assembly
            [assembly]
          else
            Decidim::Assembly.where(organization:)
          end
        end
      end
    end
  end
end
