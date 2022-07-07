# frozen_string_literal: true

module Decidim
  module Admin
    module ParticipatorySpaceExport
      extend ActiveSupport::Concern

      included do
        helper_method :exportable_space

        def create
          enforce_permission_to :create, :export_space, participatory_space: exportable_space

          Decidim.traceability.perform_action!("export", exportable_space, current_user) do
            ExportParticipatorySpaceJob.perform_later(current_user, exportable_space, manifest_name, default_format)
          end

          flash[:notice] = t("decidim.admin.exports.notice")

          redirect_back(fallback_location: after_export_path)
        end

        # Public: To be implemented at the controller. You need to
        # return the space that will be exported.
        def exportable_space
          raise NotImplementedError
        end

        # Public: To be implemented at the controller. You need to
        # return the plural of the name of the space that will be exported.
        def manifest_name
          raise NotImplementedError
        end

        # Public: Returns a String or Object that will be passed to `redirect_to` after
        # exporing a space. By default it redirects to the root_path.
        #
        # It can be redefined at controller level if you need to redirect elsewhere.
        def after_export_path
          decidim.root_path
        end

        private

        def default_format
          "JSON"
        end
      end
    end
  end
end
