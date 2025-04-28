# frozen_string_literal: true

module Decidim
  module Elections
    class ElectionsController < Admin::ApplicationController
      def index
        @elections = Election.all
      end

      def show
        @election = Election.find(params[:id])
      end
    end
  end
end
