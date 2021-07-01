# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This controller allows an admin to import results from a csv file for the Accountability component
      class ImportResultsController < Admin::ApplicationController
        def new
          @errors = []
        end

        def create
          @csv_file = params[:csv_file]
          redirect_to(new_import_path) && return if @csv_file.blank?

          Decidim::Accountability::Admin::ImportResultsCSVJob.perform_later(current_user, current_component, @csv_file.read.force_encoding("utf-8").encode("utf-8"))

          flash[:notice] = I18n.t("imports.create.success", scope: "decidim.accountability.admin")
          redirect_to import_results_path(current_participatory_space, current_component)
        end
      end
    end
  end
end
