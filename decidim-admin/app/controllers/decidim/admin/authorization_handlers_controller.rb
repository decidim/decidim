# frozen_string_literal: true

module Decidim
  module Admin
    class AuthorizationHandlersController < Decidim::Admin::ApplicationController
      layout false

      def show
        authorize! :show, :authorization_handler

        authorization_form = Decidim::AuthorizationHandler.handler_for(params[:id])

        @form = Decidim::AuthorizationFormBuilder.new(
          :authorization,
          authorization_form,
          Class.new(ActionView::Base).new,
          {}
        )
      end
    end
  end
end
