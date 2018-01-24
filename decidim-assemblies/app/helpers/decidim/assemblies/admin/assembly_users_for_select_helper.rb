# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # This class contains helpers needed to format Assemblies
      # in order to use them in select forms.
      #
      module AssemblyUsersForSelectHelper
        # Public: A formatted collection of Assemblies to be used
        # in forms.
        #
        # Returns an Array.
        def assembly_users_for_select
          @assembly_users_for_select ||=
            Decidim::User.where(organization: current_organization).map do |user|
              [user.name, user.id]
            end
        end

        def assembly_users_selected
          @assembly_users_selected ||=
            Decidim::AssemblyUser.where(assembly: current_assembly).map do |au|
              au.user.id
            end
        end
      end
    end
  end
end
