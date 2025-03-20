# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # Controller that allows managing assemblies.
      #
      class AssemblyCopiesController < Decidim::Assemblies::Admin::ApplicationController
        include Concerns::AssemblyAdmin

        def new
          enforce_permission_to :create, :assembly
          @form = form(AssemblyCopyForm).from_model(current_assembly)
        end

        def create
          enforce_permission_to :create, :assembly
          @form = form(AssemblyCopyForm).from_params(params)

          CopyAssembly.call(@form, current_assembly, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("assemblies_copies.create.success", scope: "decidim.admin")
              redirect_to assemblies_path(parent_id: current_assembly.parent_id)
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
