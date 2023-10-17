# frozen_string_literal: true

module Decidim
  module Design
    class ComponentsController < Decidim::Design::ApplicationController
      include Decidim::ControllerHelpers

      def show
        render "decidim/design/components/#{params[:id]}"
      end
    end
  end
end
