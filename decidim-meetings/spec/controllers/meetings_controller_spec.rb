# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Meetings
    describe MeetingsController, type: :controller do
      let(:organization) { create(:organization) }
      let(:feature) { create(:feature, organization: organization, manifest_name: "meetings") }
      let(:meeting) { create(:meeting, feature: feature) }

      load_routes Decidim::Meetings::ListEngine

      before do
        @request.env["decidim.current_organization"] = organization
        @request.env["decidim.current_participatory_process"] = feature.participatory_process
        @request.env["decidim.current_feature"] = feature
      end

      describe "GET static_map" do
        let(:params) do
          {
            id: meeting.id,
            feature_id: feature.id,
            participatory_process_id: feature.participatory_process.id
          }
        end
        let(:data) { "1234" }

        it "generates a static map image data using the StaticMapGenerator" do
          generator = double()

          expect(StaticMapGenerator).to receive(:new).with(meeting).and_return(generator)
          expect(generator).to receive(:data).and_return(data)
          expect(controller).to receive(:send_data).with(data, type: "image/jpeg", disposition: "inline")

          get :static_map, format: "image/jpeg", params: params
        end
      end
    end
  end
end
