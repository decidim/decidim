# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to destroy a participatory space private user.
    class DestroyParticipatorySpacePrivateUser < Decidim::Commands::DestroyResource
      private

      def extra_params
        {
          resource: {
            title: resource.user.name
          }
        }
      end
    end
  end
end
