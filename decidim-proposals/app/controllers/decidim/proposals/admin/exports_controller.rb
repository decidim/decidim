# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # This controller allows admins to manage proposals in a participatory process.
      class ExportsController < Admin::ApplicationController
        def create
          # call the new proposal export command
          authorize! :read, Proposal
          authorize! :export, Proposal

          ExportJob.perform_later(
            current_user,
            current_feature,
            params[:format]
          )

          flash[:notice] = "Exporting"
          redirect_to :back
        end
      end
    end
  end
end
