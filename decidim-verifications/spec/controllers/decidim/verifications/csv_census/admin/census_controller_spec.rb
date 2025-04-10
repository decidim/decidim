# frozen_string_literal: true

require "spec_helper"

module Decidim::Verifications::CsvCensus::Admin
  describe CensusController do
    routes { Decidim::Verifications::CsvCensus::AdminEngine.routes }

    let(:user) { create(:user, :admin, :confirmed, organization:) }
    let(:organization) { create(:organization) }
    let(:csv_datum) { create(:csv_datum, organization:) }

    before do
      request.env["decidim.current_organization"] = user.organization
      sign_in user, scope: :user
    end

    describe "GET #index" do
      before do
        allow(controller).to receive(:csv_census_active?).and_return(true)
      end

      it "renders the index template" do
        get :index
        expect(response).to render_template(:index)
      end
    end

    describe "GET #new_import" do
      before do
        allow(controller).to receive(:csv_census_active?).and_return(true)
      end

      it "assigns a new form" do
        get :new_import

        expect(response).to render_template(:new_import)
        expect(assigns(:form)).to be_a(Decidim::Verifications::CsvCensus::Admin::CensusDataForm)
      end
    end
  end
end
