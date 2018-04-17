# frozen_string_literal: true

module Decidim
  module DummyResources
    class DummyResourcesController < Decidim::Components::BaseController
      helper Decidim::Comments::CommentsHelper

      skip_authorization_check

      def show
        @commentable = DummyResources::DummyResource.find(params[:id])
      end
    end
  end
end
