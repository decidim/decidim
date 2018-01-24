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
          Decidim::Assembly.user_assembly(@user.id)
        else
          Decidim::Assembly.public_assembly
        end
      end
    end
  end
end
