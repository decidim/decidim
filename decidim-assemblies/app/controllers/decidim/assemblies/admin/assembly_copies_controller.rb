# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # Controller that allows managing assemblies.
      #
      class AssemblyCopiesController < Decidim::Admin::ApplicationController
        include Concerns::AssemblyAdmin

        def new
          authorize! :new, Decidim::Assembly
          @form = form(AssemblyCopyForm).from_model(current_assembly)
        end

        def create
          authorize! :create, Decidim::Assembly
          @form = form(AssemblyCopyForm).from_params(params)

          CopyAssembly.call(@form, current_assembly) do
            on(:ok) do
              flash[:notice] = I18n.t("assemblies_copies.create.success", scope: "decidim.admin")
              redirect_to assemblies_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("assemblies_copies.create.error", scope: "decidim.admin")
              render :new
            end
          end
        end
      end
    end
  end
end
