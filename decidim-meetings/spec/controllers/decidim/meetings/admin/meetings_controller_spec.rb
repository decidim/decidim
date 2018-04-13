# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    module Admin
      describe MeetingsController, type: :controller do
        routes { Decidim::Meetings::AdminEngine.routes }

        let(:organization) { create(:organization) }
        let(:current_user) { create(:user, :confirmed, :admin, organization: organization) }
        let(:participatory_space) { create(:participatory_process, organization: organization) }
        let!(:component) { create :component, manifest_name: "meetings", participatory_space: participatory_space }

        let(:organizer) { create(:user, :confirmed, organization: organization) }
        let(:params) { { id: organizer.id } }

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_component"] = component
          sign_in current_user
        end

        describe "GET organizers in json format" do
          context "when there are no organizers" do
            it "returns an empty json array" do
              get :organizers, format: :json, params: params.merge!(term: "#0")
              expect(response.body).to eq("[]")
            end
          end

          context "when searching by nickname" do
            it "returns the name and id for filtered organizers" do
              params[:term] = "@#{organizer.nickname}"
              get :organizers, format: :json, params: params
              expect(response.body).to eq("[[#{organizer.id},\"#{organizer.name}\",\"#{organizer.nickname}\"]]")
            end
          end

          context "when searching by name" do
            it "returns the title and id for filtered proposals" do
              params[:term] = organizer.name
              get :organizers, format: :json, params: params
              expect(response.body).to eq("[[#{organizer.id},\"#{organizer.name}\",\"#{organizer.nickname}\"]]")
            end
          end
        end
      end
    end
  end
end
