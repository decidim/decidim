# frozen_string_literal: true

module Decidim
  module Dev
    class DummyResourcesController < Decidim::Components::BaseController
      helper Decidim::Comments::CommentsHelper
      include Decidim::TranslatableAttributes

      def show
        @commentable = Dev::DummyResource.find(params[:id])
      end
    end
  end
end
