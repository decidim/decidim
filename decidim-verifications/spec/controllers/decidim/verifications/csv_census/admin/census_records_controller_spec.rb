# frozen_string_literal: true

require "spec_helper"

module Decidim::Verifications::CsvCensus::Admin
  describe CensusRecordsController do
    routes { Decidim::Verifications::CsvCensus::AdminEngine.routes }

    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, organization:) }
    let(:csv_datum) { create(:csv_datum, organization:) }

    before do
      request.env["decidim.current_organization"] = user.organization
      sign_in user, scope: :user
    end

    context "when user is admin" do
      let(:user) { create(:user, :admin, :confirmed, organization:) }

      describe "GET #new_record" do
        it "renders the new_record template" do
          expect(controller).to receive(:enforce_permission_to).with(:create, :authorization).and_call_original

          get :new_record
          expect(response).to render_template(:new_record)
          expect(assigns(:form)).to be_a(Decidim::Verifications::CsvCensus::Admin::CensusForm)
        end
      end

      describe "POST #create_record" do
        it "creates the new record" do
          expect(controller).to receive(:enforce_permission_to).with(:create, :authorization).and_call_original

          post :create_record, params: { census: { email: "test@example.org" } }

          expect(response).to have_http_status(:ok)
          expect(assigns(:form)).to be_a(Decidim::Verifications::CsvCensus::Admin::CensusForm)
        end
      end

      describe "GET #edit_record" do
        it "renders the edit_record template" do
          expect(controller).to receive(:enforce_permission_to).with(:update, :authorization).and_call_original

          get :edit_record, params: { id: csv_datum.id }
          expect(response).to render_template(:edit_record)
          expect(assigns(:form)).to be_a(Decidim::Verifications::CsvCensus::Admin::CensusForm)
        end
      end

      describe "PATCH #update_record" do
        it "updates the record" do
          expect(controller).to receive(:enforce_permission_to).with(:update, :authorization).and_call_original

          patch :update_record, params: { id: csv_datum.id, census: { email: "test@example.org" } }

          expect(assigns(:form)).to be_a(Decidim::Verifications::CsvCensus::Admin::CensusForm)
          expect(response).to have_http_status(:ok)
          expect(csv_datum.reload.email).to eq("test@example.org")
        end
      end
    end

    context "when user is NOT admin" do
      let(:user) { create(:process_admin, :confirmed, organization:, participatory_process:) }

      describe "GET #new_record" do
        it "prohibits display new record page using redirect" do
          get :new_record

          expect(response).to have_http_status(:redirect)
        end
      end

      describe "POST #create_record" do
        it "prohibits creating new records by using redirect" do
          post :create_record, params: { id: csv_datum.id }

          expect(response).to have_http_status(:redirect)
        end
      end

      describe "GET #edit_record" do
        it "prohibits display edit record page using redirect" do
          get :edit_record, params: { id: csv_datum.id }

          expect(response).to have_http_status(:redirect)
        end
      end

      describe "PATCH #update_record" do
        it "prohibits record update page using redirect" do
          patch :update_record, params: { id: csv_datum.id }

          expect(response).to have_http_status(:redirect)
        end
      end
    end
  end
end
