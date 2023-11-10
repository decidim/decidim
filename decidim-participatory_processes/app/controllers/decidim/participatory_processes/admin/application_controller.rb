# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # The main admin application controller for participatory processes
      class ApplicationController < Decidim::Admin::ApplicationController
        register_permissions(::Decidim::ParticipatoryProcesses::Admin::ApplicationController,
                             ::Decidim::ParticipatoryProcesses::Permissions,
                             ::Decidim::Admin::Permissions)

        private

        helper_method :tabs

        def permissions_context
          super.merge(
            current_participatory_space: try(:current_participatory_space)
          )
        end

        def permission_class_chain
          ::Decidim.permissions_registry.chain_for(::Decidim::ParticipatoryProcesses::Admin::ApplicationController)
        end

        def tabs
          @tabs ||= items.map { |item| item.slice(:id, :text, :icon) }
        end

        def panels
          @panels ||= items.map { |item| item.slice(:id, :method, :args) }
        end

        def items
          @items ||= [
            {
              id: "images",
              text: t("decidim.application.photos.photos"),
              icon: "upload-line",
              method: :cell,
              args: ["decidim/images_panel", @current_initiative]
            },
            {
              id: "documents",
              text: t("decidim.application.documents.documents"),
              icon: "upload-line",
              method: :cell,
              args: ["decidim/documents_panel", @current_initiative]
            }
          ].select { |item| item[:enabled] }
        end
      end
    end
  end
end
