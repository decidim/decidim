# frozen_string_literal: true

module Decidim
  module Admin
    module ParticipatorySpace
      module Concerns
        # Members can be related to any ParticipatorySpace, in order to
        # import members from csv for a given type, you should create a new
        # controller and include this concern.
        #
        # The only requirement is to define a `participatory_space` method that
        # returns an instance of the model to relate the member to.
        module HasMembersCsvImport
          extend ActiveSupport::Concern

          included do
            helper_method :participatory_space

            def new
              enforce_permission_to :csv_import, :space_member
              @form = form(MemberCsvImportForm).from_params({}, participatory_space:)
              @count = Decidim::ParticipatorySpace::Member.by_participatory_space(participatory_space).count
              render template: "decidim/admin/members_csv_imports/new"
            end

            def create
              enforce_permission_to :csv_import, :space_member
              @form = form(MemberCsvImportForm).from_params(params, participatory_space:)

              ImportMemberCsv.call(@form, current_participatory_space) do
                on(:ok) do
                  flash[:notice] = I18n.t("members_csv_imports.create.success", scope: "decidim.admin")
                  redirect_to after_import_path
                end

                on(:invalid) do
                  flash[:alert] = I18n.t("members_csv_imports.create.invalid", scope: "decidim.admin")
                  render template: "decidim/admin/members_csv_imports/new", status: :unprocessable_entity
                end
              end
            end

            def destroy_all
              enforce_permission_to :csv_import, :space_member
              Decidim::ParticipatorySpace::Member.by_participatory_space(participatory_space).delete_all
              redirect_to new_members_csv_imports_path
            end

            # Public: Returns a String or Object that will be passed to `redirect_to` after
            # importing members. By default it redirects to the participatory_space.
            #
            # It can be redefined at controller level if you need to redirect elsewhere.
            def after_import_path
              participatory_space
            end

            # Public: The only method to be implemented at the controller. You need to
            # return the object where the attachment will be attached to.
            def participatory_space
              raise NotImplementedError
            end
          end
        end
      end
    end
  end
end
