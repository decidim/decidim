# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # Custom helpers, scoped to the meetings admin engine.
      #
      module ApplicationHelper
        include Decidim::MapHelper

        def tabs_id_for_service(service)
          "meeting_service_#{service.to_param}"
        end
      end
    end
  end
end
