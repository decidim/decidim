# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This controller allows an admin to import results from a csv file for the Accountability feature
      class ImportsController < Admin::ApplicationController

        def new
          @errors = []
        end

        def create
          @csv_file = params[:csv_file]
          redirect_to new_import_path and return unless @csv_file.present?

          i = CSVImporter.new(current_feature, @csv_file.path)
          @errors = i.import!
          if @errors.empty?
            flash[:notice] = I18n.t("imports.create.success", scope: "decidim.accountability.admin")
            redirect_to new_import_path
          else
            flash.now[:error] = I18n.t("imports.create.invalid", scope: "decidim.accountability.admin")
            render :new
          end
        end
      end
    end
  end
end
