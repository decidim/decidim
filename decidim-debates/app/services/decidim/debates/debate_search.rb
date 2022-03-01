# frozen_string_literal: true

module Decidim
  module Debates
    # This service scopes the debate searches with parameters that cannot be
    # passed from the user interface.
    class DebateSearch < ResourceSearch
      attr_reader :activity

      def build(params)
        @activity = params[:activity]

        if params[:activity] && user
          case params[:activity]
          when "commented"
            add_scope(:commented_by, user)
          when "my_debates"
            add_scope(:authored_by, user)
          end
        end

        super
      end
    end
  end
end
