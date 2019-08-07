# frozen_string_literal: true

module Decidim
  module Blogs
    module Admin
      # Base controller for the administration of this module. It inherits from
      # Decidim's admin base controller in order to inherit the layout and other
      # convenience methods relevant to a this component.
      class ApplicationController < Decidim::Admin::Components::BaseController
        helper_method :posts, :post

        def posts
          @posts ||= Post.where(component: current_component).page(params[:page]).per(15)
        end

        def post
          @post ||= posts.find(params[:id])
        end
      end
    end
  end
end
