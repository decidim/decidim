# frozen_string_literal: true

module Decidim
  module Admin
    module Concerns
      # PrivateUsers can be related to any ParticipatorySpace, in order to
      # import private users from csv for a given type, you should create a new
      # controller and include this concern.
      #
      # The only requirement is to define a `privatable_to` method that
      # returns an instance of the model to relate the private_user to.
      module HasPrivateUsersCsvImport
        extend ActiveSupport::Concern

        included do
          helper_method :privatable_to

          def new
            enforce_permission_to :csv_import, :space_private_user
            @form = form(ParticipatorySpacePrivateUserCsvImportForm).from_params({}, privatable_to:)
            @count = Decidim::ParticipatorySpacePrivateUser.by_participatory_space(privatable_to).count
            render template: "decidim/admin/participatory_space_private_users_csv_imports/new"
          end

          def create
            enforce_permission_to :csv_import, :space_private_user
            @form = form(ParticipatorySpacePrivateUserCsvImportForm).from_params(params, privatable_to:)

            ProcessParticipatorySpacePrivateUserImportCsv.call(@form, current_user, current_participatory_space) do
              on(:ok) do
                flash[:notice] = I18n.t("participatory_space_private_users_csv_imports.create.success", scope: "decidim.admin")
                redirect_to after_import_path
              end

              on(:invalid) do
                flash[:alert] = I18n.t("participatory_space_private_users_csv_imports.create.invalid", scope: "decidim.admin")
                render template: "decidim/admin/participatory_space_private_users_csv_imports/new"
              end
            end
          end

          def destroy_all
            enforce_permission_to :csv_import, :space_private_user
            Decidim::ParticipatorySpacePrivateUser.by_participatory_space(privatable_to).delete_all
            redirect_to new_participatory_space_private_users_csv_imports_path
          end

          # Public: Returns a String or Object that will be passed to `redirect_to` after
          # importing private users. By default it redirects to the privatable_to.
          #
          # It can be redefined at controller level if you need to redirect elsewhere.
          def after_import_path
            privatable_to
          end

          # Public: The only method to be implemented at the controller. You need to
          # return the object where the attachment will be attached to.
          def privatable_to
            raise NotImplementedError
          end
        end
      end
    end
  end
end
