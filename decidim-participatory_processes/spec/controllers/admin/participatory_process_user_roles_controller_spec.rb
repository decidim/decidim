# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryProcesses
    module Admin
      describe ParticipatoryProcessUserRolesController, type: :controller do
        routes { Decidim::ParticipatoryProcesses::AdminEngine.routes }

        let(:organization) { create(:organization) }
        let(:current_user) { create(:user, :confirmed, :admin, organization:) }
        let!(:participatory_process) do
          create(
            :participatory_process,
            :published,
            organization:
          )
        end

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_participatory_process"] = participatory_process
          sign_in current_user
        end

        describe "creates new participatory process admin" do
          let(:new_pp_admin_name) { "new pp admin name" }
          let(:new_pp_admin_email) { "pp_admin@mail.com" }
          let(:new_pp_admin_params) do
            {
              participatory_process_user_role: {
                name: new_pp_admin_name,
                email: new_pp_admin_email,
                role: "admin"
              },
              participatory_process_slug: participatory_process.slug
            }
          end

          describe "with a valid nickname" do
            it "create new admin successfully" do
              post(:create, params: new_pp_admin_params)
              expect(response).to redirect_to(participatory_process_user_roles_path(participatory_process.slug))
              expect(flash[:notice]).to be_present
              expect(flash[:alert]).not_to be_present
            end
          end

          describe "with an invalid nickname" do
            let(:new_pp_admin_name) { "new pp (admin) name" }

            it "must detect invalid nickname chars" do
              post(:create, params: new_pp_admin_params)
              expect(flash[:alert]).to be_present
              expect(flash[:notice]).not_to be_present
            end
          end
        end
      end
    end
  end
end
