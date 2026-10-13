# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Conferences
    describe Admin::RegistrationTypesController do
      routes { Decidim::Conferences::AdminEngine.routes }

      let(:organization) { create(:organization) }
      let(:current_user) { create(:user, :confirmed, :admin, organization:) }
      let!(:conference) do
        create(
          :conference,
          :published,
          registrations_enabled: true,
          organization:
        )
      end
      let!(:registration_types) { create_list(:registration_type, 2, conference:) }

      before do
        request.env["decidim.current_organization"] = organization
        sign_in current_user
      end

      describe "GET index" do
        it "renders successfully" do
          get :index, params: { conference_slug: conference.slug }

          expect(response).to have_http_status(:ok)
        end
      end

      describe "DELETE destroy" do
        it "destroys a registration type without registrations" do
          expect do
            delete :destroy, params: { conference_slug: conference.slug, id: registration_types.first.id }
          end.to change(Decidim::Conferences::RegistrationType, :count).by(-1)
        end

        context "when the registration type has registrations" do
          let(:registration_type) { registration_types.last }

          before do
            create(:conference_registration, conference:, registration_type:, user: create(:user, :confirmed, organization:))
          end

          it "does not destroy the registration type" do
            expect do
              delete :destroy, params: { conference_slug: conference.slug, id: registration_type.id }
            end.not_to change(Decidim::Conferences::RegistrationType, :count)

            expect(flash[:alert]).to eq(I18n.t("registration_types.destroy.error", scope: "decidim.admin"))
          end
        end
      end
    end
  end
end
