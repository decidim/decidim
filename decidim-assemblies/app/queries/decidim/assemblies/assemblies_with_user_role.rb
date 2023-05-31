# frozen_string_literal: true

module Decidim
  module Assemblies
    # A class used to find the Assemblies that the given user has
    # the specific role privilege.
    class AssembliesWithUserRole < Decidim::Query
      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # user - a User that needs to find which assemblies can manage
      # role - (optional) a Symbol to specify the role privilege
      def self.for(user, role = :any)
        new(user, role).query
      end

      # Initializes the class.
      #
      # user - a User that needs to find which assemblies can manage
      # role - (optional) a Symbol to specify the role privilege
      def initialize(user, role = :any)
        @user = user
        @role = role
      end

      # Finds the Assemblies that the given user has role privileges.
      # If the special role ':any' is provided it returns all assemblies where
      # the user has some kind of role privilege.
      #
      # Returns an ActiveRecord::Relation.
      def query
        # Admin users have all role privileges for all organization assemblies
        return Assemblies::OrganizationAssemblies.new(user.organization).query if user.admin?

        Assembly.where(id: assembly_ids)
      end

      private

      attr_reader :user, :role

      def assembly_ids
        user_roles = AssemblyUserRole.where(user:) if role == :any
        user_roles = AssemblyUserRole.where(user:, role:) if role != :any
        user_roles.pluck(:decidim_assembly_id)
      end
    end
  end
end
