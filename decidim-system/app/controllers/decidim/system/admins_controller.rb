# frozen_string_literal: true
require_dependency "decidim/system/application_controller"

module Decidim
  module System
    # Controller that allows managing all the Admins.
    #
    class AdminsController < ApplicationController
      def index
        @admins = Admin.all
      end

      def show
        @admin = Admin.find(params[:id])
      end
    end
  end
end
