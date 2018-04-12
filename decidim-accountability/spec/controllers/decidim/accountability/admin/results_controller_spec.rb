# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Accountability
    module Admin
      describe ResultsController, type: :controller do
        routes { Decidim::Accountability::AdminEngine.routes }

        let(:organization) { create(:organization) }
        let(:current_user) { create(:user, :confirmed, :admin, organization: organization) }
        let(:participatory_space) { create(:participatory_process, organization: organization) }
        let!(:feature) do
          create(
            :accountability_feature,
            participatory_space: participatory_space
          )
        end
        let(:result) { create(:result, feature: feature) }
        let(:params) { { id: result.id } }

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_feature"] = feature
          sign_in current_user
        end

        describe "GET proposals in html format" do
          it "renders the data-picker proposal selector" do
            get :proposals, format: :html, params: params
            expect(response).to render_template("decidim/accountability/admin/results/_proposals")
          end
        end

        describe "GET proposals in json format" do
          let(:proposal_feature) { create(:proposal_feature, participatory_space: participatory_space) }
          let(:proposal) { create(:proposal, feature: proposal_feature) }

          context "when there are no results" do
            it "returns an empty json array" do
              get :proposals, format: :json, params: params.merge!(term: "#0")
              expect(response.body).to eq("[]")
            end
          end

          context "when searching by id" do
            it "returns the title and id for filtered proposals" do
              params[:term] = "##{proposal.id}"
              get :proposals, format: :json, params: params
              expect(response.body).to eq("[[\"#{proposal.title}\",#{proposal.id}]]")
            end
          end

          context "when searching by term" do
            it "returns the title and id for filtered proposals" do
              params[:term] = proposal.title
              get :proposals, format: :json, params: params
              expect(response.body).to eq("[[\"#{proposal.title}\",#{proposal.id}]]")
            end
          end
        end
      end
    end
  end
end
