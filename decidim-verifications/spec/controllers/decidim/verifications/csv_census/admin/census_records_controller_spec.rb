# frozen_string_literal: true

require "spec_helper"

module Decidim::Verifications::CsvCensus::Admin
  describe CensusRecordsController do
    routes { Decidim::Verifications::CsvCensus::AdminEngine.routes }

    let(:user) { create(:user, :admin, :confirmed, organization:) }
    let(:organization) { create(:organization) }
    let(:csv_datum) { create(:csv_datum, organization:) }

    before do
      request.env["decidim.current_organization"] = user.organization
      sign_in user, scope: :user
    end

    describe "GET #new_record" do
      it "renders the new_record template" do
        get :new_record
        expect(response).to render_template(:new_record)
        expect(assigns(:form)).to be_a(Decidim::Verifications::CsvCensus::Admin::CensusForm)
      end
    end

    describe "GET #edit_record" do
      it "renders the edit_record template" do
        get :edit_record, params: { id: csv_datum.id }
        expect(response).to render_template(:edit_record)
        expect(assigns(:form)).to be_a(Decidim::Verifications::CsvCensus::Admin::CensusForm)
      end
    end
  end
end
