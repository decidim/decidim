# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe OrganizationController do
      routes { Decidim::Admin::Engine.routes }

      let(:organization) { create(:organization) }
      let(:current_user) { create(:user, :admin, :confirmed, organization:) }

      before do
        request.env["decidim.current_organization"] = organization
        sign_in current_user, scope: :user
      end

      describe "GET #edit" do
        it "renders the edit template" do
          get :edit

          expect(response).to render_template(:edit)
          expect(assigns(:form).id).to eq(organization.id)
          expect(assigns(:form).name).to eq(organization.name)
        end
      end

      describe "PATCH #update" do
        let(:attributes) { attributes_for(:organization) }
        let(:params) do
          {
            organization: attributes.merge(
              name: attributes[:name].merge(en: "My updated organization"),
              description: attributes[:description].merge(en: "Updated description")
            )
          }
        end

        it "updates the organization and redirects" do
          patch(:update, params:)

          expect(response).to redirect_to(edit_organization_path)
          expect(flash[:notice]).to eq(I18n.t("organization.update.success", scope: "decidim.admin"))
          expect(translated(organization.reload.name)).to eq("My updated organization")
        end

        it "renders edit when invalid" do
          patch :update, params: params.deep_merge(organization: { name: { en: "" } })

          expect(response).to have_http_status(:unprocessable_content)
          expect(response).to render_template(:edit)
          expect(flash.now[:alert]).to eq(I18n.t("organization.update.error", scope: "decidim.admin"))
        end
      end
    end
  end
end
