# frozen_string_literal: true

module Decidim
  module Assemblies
    # This query class filters assemblies given a current_user.
    class VisibleAssemblies < Rectify::Query
      def initialize(user)
        @user = user
      end

      def query
        assemblies = Decidim::Assembly

        if @user
          return assemblies.all if @user.admin
          assemblies.visible_for(@user)
        else
          assemblies.public_spaces
        end
      end
    end
  end
end
