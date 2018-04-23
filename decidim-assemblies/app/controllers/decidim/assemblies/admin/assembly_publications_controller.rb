# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # Controller that allows managing assembly publications.
      #
      class AssemblyPublicationsController < Decidim::Admin::ApplicationController
        include Concerns::AssemblyAdmin

        def create
          authorize! :publish, current_assembly

          PublishAssembly.call(current_assembly, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("assembly_publications.create.success", scope: "decidim.admin")
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("assembly_publications.create.error", scope: "decidim.admin")
            end

            redirect_back(fallback_location: assemblies_path)
          end
        end

        def destroy
          authorize! :publish, current_assembly

          UnpublishAssembly.call(current_assembly, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("assembly_publications.destroy.success", scope: "decidim.admin")
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("assembly_publications.destroy.error", scope: "decidim.admin")
            end

            redirect_back(fallback_location: assemblies_path)
          end
        end

        def current_participatory_space_manifest_name
          :assemblies
        end
      end
    end
  end
end
