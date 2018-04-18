# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # The main admin application controller for consultations
      class ApplicationController < Decidim::Admin::ApplicationController
        layout "decidim/admin/consultations"

        helper Decidim::SanitizeHelper

        def current_participatory_space_manifest_name
          :consultations
        end
      end
    end
  end
end
