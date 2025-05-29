# frozen_string_literal: true

require "spec_helper"

module Decidim::Accountability
  describe Admin::ResultsBulkActionsController do

    let(:organization) { create(:organization) }
    let(:participatory_space) { create(:participatory_process, organization:) }
    let(:current_component) { create(:accountability_component, participatory_space:) }
    let(:results) { create_list(:result, 3, component: current_component) }
    let(:result_ids) { results.map(&:id) }
    let(:current_user) { create(:user, :confirmed, :admin, organization:) }

    before do
      allow(controller).to receive(:results_path).and_return(Decidim::EngineRouter.admin_proxy(current_component).results_path)
      request.env["decidim.current_organization"] = organization
      request.env["decidim.current_component"] = current_component
      sign_in current_user
    end

    describe "POST update_status" do
      let(:status) { create(:status, component: current_component) }
      let(:params) do
        {
          result_bulk_actions: {
            decidim_accountability_status_id: status.id,
            result_ids:
          }
        }
      end

      it "updates the status of the results" do
        post(:update_status, params:)

        expect(response).to have_http_status(:found)
        results.each do |result|
          expect(result.reload.status).to eq(status)
        end
      end

      context "when parameters are invalid" do
        let(:params) do
          {
            result_bulk_actions: {
              decidim_accountability_status_id: nil,
              result_ids:
            }
          }
        end

        it "redirects with an error message" do
          post(:update_status, params:)

          expect(response).to have_http_status(:found)
          expect(flash[:alert]).not_to be_empty
        end
      end
    end

    describe "POST update_dates" do
      let(:start_date) { Date.current }
      let(:end_date) { Date.current + 1.month }
      let(:params) do
        {
          result_bulk_actions: {
            start_date:,
            end_date:,
            result_ids:
          }
        }
      end

      it "updates the dates of the results" do
        post(:update_dates, params:)

        expect(response).to have_http_status(:found)
        results.each do |result|
          expect(result.reload.start_date).to eq(start_date)
          expect(result.reload.end_date).to eq(end_date)
        end
      end

      context "when parameters are invalid" do
        let(:params) do
          {
            result_bulk_actions: {
              start_date: nil,
              end_date: nil,
              result_ids:
            }
          }
        end

        it "redirects with an error message" do
          post(:update_dates, params:)

          expect(response).to have_http_status(:found)
          expect(flash[:alert]).not_to be_empty
        end
      end
    end

    describe "POST update_taxonomies" do
      let(:taxonomy) { create(:taxonomy, :with_parent, organization:) }
      let(:params) do
        {
          result_bulk_actions: {
            taxonomies: [taxonomy.id],
            result_ids:
          }
        }
      end

      it "updates the taxonomies of the results" do
        post(:update_taxonomies, params:)

        expect(response).to have_http_status(:found)
        results.each do |result|
          expect(result.reload.taxonomies.first).to eq(taxonomy)
        end
      end

      context "when parameters are invalid" do
        let(:params) do
          {
            result_bulk_actions: {
              taxonomies: [],
              result_ids:
            }
          }
        end

        it "redirects with an error message" do
          post(:update_taxonomies, params:)

          expect(response).to have_http_status(:found)
          expect(flash[:alert]).not_to be_empty
        end
      end
    end

    context "when user is not authorized" do
      let(:unauthorized_user) { create(:user, :confirmed, organization:) }
      let(:status) { create(:status, component: current_component) }
      let(:params) do
        {
          result_bulk_actions: {
            decidim_accountability_status_id: status.id,
            result_ids:
          }
        }
      end

      before do
        sign_in unauthorized_user
      end

      it "is not able to perform bulk actions" do
        post(:update_status, params:)

        expect(response).to have_http_status(:redirect)
        expect(flash[:alert]).not_to be_empty
      end
    end
  end
end
