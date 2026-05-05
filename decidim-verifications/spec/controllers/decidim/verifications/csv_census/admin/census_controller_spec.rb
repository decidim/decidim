# frozen_string_literal: true

require "spec_helper"

module Decidim::Verifications::CsvCensus::Admin
  describe CensusController do
    routes { Decidim::Verifications::CsvCensus::AdminEngine.routes }

    let(:user) { create(:user, :admin, :confirmed, organization:) }
    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, organization:) }
    let(:csv_datum) { create(:csv_datum, organization:) }

    before do
      allow(controller).to receive(:csv_census_active?).and_return(true)
      request.env["decidim.current_organization"] = user.organization
      sign_in user, scope: :user
    end

    describe "GET #index" do
      it "enforces permission to index authorizations" do
        expect(controller).to receive(:enforce_permission_to).with(:index, :authorization)

        get :index
      end

      it "renders the index template" do
        get :index
        expect(response).to render_template(:index)
      end
    end

    describe "DELETE #destroy" do
      it "enforces permission to destroy authorizations" do
        expect(controller).to receive(:enforce_permission_to).with(:destroy, :authorization)

        delete :destroy, params: { id: csv_datum.id }
      end
    end

    describe "GET #new_import" do
      it "enforces permission to create authorizations" do
        expect(controller).to receive(:enforce_permission_to).with(:create, :authorization)

        get :new_import
      end

      it "assigns a new form" do
        get :new_import

        expect(response).to render_template(:new_import)
        expect(assigns(:form)).to be_a(Decidim::Verifications::CsvCensus::Admin::CensusDataForm)
      end
    end

    describe "POST #create_import" do
      before do
        form_errors = instance_double(ActiveModel::Errors, any?: true, full_messages: ["File cannot be blank"])
        form = instance_double(Decidim::Verifications::CsvCensus::Admin::CensusDataForm, validate_csv: nil, errors: form_errors)
        form_builder = double(from_params: form)

        allow(controller).to receive(:form).and_return(form_builder)
      end

      it "enforces permission to create authorizations" do
        expect(controller).to receive(:enforce_permission_to).with(:create, :authorization)

        post :create_import
      end
    end

    context "when user is a process admin" do
      let(:user) { create(:process_admin, :confirmed, organization:, participatory_process:) }

      it "does not allow index" do
        get :index

        expect(response).to have_http_status(:redirect)
      end

      it "does not allow destroy" do
        delete :destroy, params: { id: csv_datum.id }

        expect(response).to have_http_status(:redirect)
      end

      it "does not allow new_import" do
        get :new_import

        expect(response).to have_http_status(:redirect)
      end

      it "does not allow create_import" do
        post :create_import

        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
