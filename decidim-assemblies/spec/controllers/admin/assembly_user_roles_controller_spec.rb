# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Assemblies
    module Admin
      describe AssemblyUserRolesController, type: :controller do
        routes { Decidim::Assemblies::AdminEngine.routes }

        let(:organization) { create(:organization) }
        let(:current_user) { create(:user, :confirmed, :admin, organization:) }
        let!(:assembly) do
          create(
            :assembly,
            :published,
            organization:
          )
        end

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_assembly"] = assembly
          sign_in current_user
        end

        describe "creates new assembly admin" do
          let(:new_assembly_admin_name) { "new assembly admin name" }
          let(:new_assembly_admin_email) { "assembly_admin@mail.com" }
          let(:new_assembly_admin_params) do
            {
              assembly_user_role: {
                name: new_assembly_admin_name,
                email: new_assembly_admin_email,
                role: "admin"
              },
              assembly_slug: assembly.slug
            }
          end

          describe "with a valid nickname" do
            it "create new admin successfully" do
              post(:create, params: new_assembly_admin_params)
              expect(response).to redirect_to(assembly_user_roles_path(assembly.slug))
              expect(flash[:notice]).to be_present
              expect(flash[:alert]).not_to be_present
            end
          end

          describe "with an invalid nickname" do
            let(:new_assembly_admin_name) { "new assembly (admin) name" }

            it "must detect invalid nickname chars" do
              post(:create, params: new_assembly_admin_params)
              expect(flash[:alert]).to be_present
              expect(flash[:notice]).not_to be_present
            end
          end
        end
      end
    end
  end
end
