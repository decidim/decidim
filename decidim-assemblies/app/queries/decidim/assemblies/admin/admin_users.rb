# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A class used to find the admins for an assembly.
      class AdminUsers < Rectify::Query
        # Syntactic sugar to initialize the class and return the queried objects.
        #
        # assembly - an assembly that needs to find its assembly admins
        def self.for(assembly)
          new(assembly).query
        end

        # Initializes the class.
        #
        # assembly - an assembly that needs to find its assembly admins
        def initialize(assembly)
          @assembly = assembly
        end

        # Finds organization admins and the users with role admin for the given assembly.
        #
        # Returns an ActiveRecord::Relation.
        def query
          Decidim::User.where(id: organization_admins).or(assembly_user_admins)
        end

        private

        attr_reader :assembly

        def organization_admins
          assembly.organization.admins
        end

        def assembly_user_admins
          assembly_user_admin_ids = Decidim::AssemblyUserRole
                                    .where(assembly: assembly, role: :admin)
                                    .pluck(:decidim_user_id)
          Decidim::User.where(id: assembly_user_admin_ids)
        end
      end
    end
  end
end
