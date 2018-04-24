# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # The main admin application controller for initiatives
      class ApplicationController < Decidim::Admin::ApplicationController
        layout "decidim/admin/initiatives"
      end
    end
  end
end
