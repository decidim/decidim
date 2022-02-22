# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Meetings
    # A controller concern to specify default filter parameters for the controller resources.
    module Filterable
      extend ActiveSupport::Concern

      included do
        private

        def default_filter_type_params
          %w(all) + Decidim::Meetings::Meeting::TYPE_OF_MEETING
        end

        def default_filter_origin_params
          filter_origin_params = %w(participants)
          filter_origin_params << "official"
          filter_origin_params << "user_group" if current_organization.user_groups_enabled?
          filter_origin_params
        end
      end
    end
  end
end
