# frozen_string_literal: true

module Decidim
  module Proposals
    # This service scopes the proposal searches with parameters that cannot be
    # passed from the user interface.
    class ProposalSearch < ResourceSearch
      attr_reader :type, :activity

      def build(params)
        return super if search_context == :admin

        @type = params[:type]
        @activity = params[:activity]

        if params[:activity] && user
          case params[:activity]
          when "voted"
            add_scope(:voted_by, user)
          when "my_proposals"
            add_scope(:coauthored_by, user)
          end
        end
        add_scope(:with_type, [params[:type], user, component]) if params[:type]

        super
      end
    end
  end
end
