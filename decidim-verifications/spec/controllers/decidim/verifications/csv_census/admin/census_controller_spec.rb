# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Verifications
    module CsvCensus
      module Admin
        describe CensusController do
          routes { Decidim::Verifications::CsvCensus::AdminEngine.routes }

          let(:organization) { create(:organization) }
          let(:current_user) { create(:user, :confirmed, :admin, organization:) }

          before do
            sign_in current_user
          end

          describe "GET #new" do
            it "initializes a new Census form" do
              get :new
              expect(assigns(:form)).to be_a(Admin::CensusForm)
            end
          end

          describe "POST #create" do
            let(:valid_params) { { census_form: attributes_for(:census_form) } }

            context "when valid" do
              it "creates a new census record and redirects" do
                post :create, params: valid_params
                expect(flash[:notice]).to eq("success")
                expect(response).to redirect_to(census_records_path)
              end
            end

            context "when invalid" do
              it "does not create a census record and renders index" do
                allow(controller).to receive(:form).with(Admin::CensusForm).and_return(form)
                post :create, params: valid_params
                expect(flash.now[:alert]).to eq("error")
                expect(response).to render_template(:index)
              end
            end
          end

          describe "GET #edit" do
            let(:census_record) { create(:csv_datum, organization: organization) }

            it "loads the correct census data" do
              get :edit, params: { id: census_record.id }
              expect(assigns(:form)).to be_a(Admin::CensusForm)
            end
          end

          describe "PUT #update" do
            let(:census_record) { create(:csv_datum, organization: organization) }
            let(:valid_params) { { census_form: attributes_for(:census_form) } }

            context "when valid" do
              it "updates the census record and redirects" do
                put :update, params: { id: census_record.id, census_form: valid_params }
                expect(flash[:notice]).to eq("success")
                expect(response).to redirect_to(census_records_path)
              end
            end

            context "when invalid" do
              it "does not update the census record and renders edit" do
                allow(controller).to receive(:form).with(Admin::CensusForm).and_return(form)
                put :update, params: { id: census_record.id, census_form: valid_params }
                expect(flash.now[:alert]).to eq("error")
                expect(response).to render_template(:edit)
              end
            end
          end

          describe "DELETE #destroy" do
            let(:census_record) { create(:csv_datum, organization: organization) }

            it "destroys the census record and redirects" do
              delete :destroy, params: { id: census_record.id }
              expect(flash[:notice]).to eq("success")
              expect(response).to redirect_to(census_records_path)
            end
          end
        end
      end
    end
  end
end
