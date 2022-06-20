# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      class AssemblyImportsController < Decidim::Assemblies::Admin::ApplicationController
        def new
          enforce_permission_to :import, :assembly
          @form = form(AssemblyImportForm).instance
        end

        def create
          enforce_permission_to :import, :assembly
          @form = form(AssemblyImportForm).from_params(params)

          ImportAssembly.call(@form, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("assembly_imports.create.success", scope: "decidim.admin")
              redirect_to assemblies_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("assembly_imports.create.error", scope: "decidim.admin")
              render :new
            end
          end
        end
      end
    end
  end
end
