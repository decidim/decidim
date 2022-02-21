# frozen_string_literal: true

module Decidim
  module Initiatives
    # This service scopes the meeting searches with parameters that cannot be
    # passed from the user interface.
    class InitiativeSearch < ResourceSearch
      attr_reader :author

      def build(params)
        return super if search_context == :admin

        @author = params[:author]

        if params[:author] == "myself" && user
          add_scope(:authored_by, user)
        else
          add_scope(:published, nil)
        end

        super
      end
    end
  end
end
