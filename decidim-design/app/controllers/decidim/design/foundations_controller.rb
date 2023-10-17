# frozen_string_literal: true

module Decidim
  module Design
    class FoundationsController < Decidim::Design::ApplicationController
      include Decidim::ControllerHelpers

      def show
        render "decidim/design/foundations/#{params[:id]}"
      end
    end
  end
end
