# frozen_string_literal: true

module Decidim
  module Assemblies
    # This query class filters assemblies given a current_user.
    class VisibleAssemblies < Rectify::Query
      def initialize(user)
        @user = user
      end

      def query
        assemblies = Decidim::Assembly.all

        if @user
          return assemblies if @user.admin
          assemblies.visible_for(@user.id)
        else
          assemblies.public_spaces
        end
      end
    end
  end
end
