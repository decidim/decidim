# frozen_string_literal: true

module Decidim
  module Assemblies
    # This query class filters assemblies given a current_user.
    class PrivateAssemblies < Rectify::Query
      def initialize(user)
        @user = user
      end

      def query
        if @user
          Decidim::Assembly.private_spaces_user(@user.id)
        else
          Decidim::Assembly.non_private_assemblies
        end
      end
    end
  end
end
