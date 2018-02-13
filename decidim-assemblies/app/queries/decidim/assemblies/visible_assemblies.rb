# frozen_string_literal: true

module Decidim
  module Assemblies
    # This query class filters assemblies given a current_user.
    class VisibleAssemblies < Rectify::Query
      def initialize(user)
        @user = user
      end

      def query
        if @user
          Decidim::Assembly.visible_assemblies_for(@user.id)
        else
          Decidim::Assembly.non_private_spaces
        end
      end
    end
  end
end
