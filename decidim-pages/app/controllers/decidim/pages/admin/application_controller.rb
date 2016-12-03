# frozen_string_literal: true
require_dependency "decidim/admin/features/base_controller"

module Decidim
  module Pages
    module Admin
      # Base controller for the administration of this module. It inherits from
      # Decidim's admin base controller in order to inherit the layout and other
      # convenience methods relevant to a this component.
      class ApplicationController < Decidim::Admin::Features::BaseController
      end
    end
  end
end
