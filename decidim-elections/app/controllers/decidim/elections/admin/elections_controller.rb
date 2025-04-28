module Decidim
  module Elections
    module Admin
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
end
