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
    end
  end
end
