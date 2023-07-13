# frozen_string_literal: true

module Decidim
  module DummyResources
    class DummyResourcesController < Decidim::Components::BaseController
      helper Decidim::Comments::CommentsHelper
      include Decidim::TranslatableAttributes

      redesign_participatory_space_layout only: :show

      def show
        @commentable = DummyResources::DummyResource.find(params[:id])
      end
    end
  end
end
