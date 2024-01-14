# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::Directory::MeetingsController do
  routes { Decidim::Meetings::DirectoryEngine.routes }

  let(:organization) { create(:organization) }
  let(:participatory_process1) { create(:participatory_process, organization:) }
  let(:meeting_component1) { create(:meeting_component, :with_creation_enabled, participatory_space: participatory_process1) }
  let(:participatory_process2) { create(:participatory_process, organization:) }
  let(:meeting_component2) { create(:meeting_component, :with_creation_enabled, participatory_space: participatory_process2) }

  let!(:meetings) do
    [].tap do |list|
      list << create(:meeting, :published, :upcoming, title: { en: "First meeting" }, attending_organizations: "Decidim", component: meeting_component1)
      list << create(:meeting, :published, :upcoming, title: { en: "Second meeting" }, component: meeting_component1)
      list << create(:meeting, :published, :upcoming, title: { en: "Third meeting" }, component: meeting_component2)
    end
  end

  before do
    request.env["decidim.current_organization"] = organization
  end

  describe "#show" do
    render_views

    let(:params) { { filter: filter_params } }
    let(:filter_params) { {} }

    before do
      get :calendar, params:
    end

    it { expect(response).to have_http_status(:success) }

    context "with an allowed parameter" do
      let(:filter_params) { { title_or_description_cont: "First meeting" } }

      it "allows filtering" do
        expect(response.body).to include("First meeting")
        expect(response.body.scan("BEGIN:VEVENT").size).to eq(1)
      end
    end

    context "with a disallowed parameter" do
      let(:filter_params) { { attending_organizations_eq: "Decidim" } }

      it "does not allow filtering" do
        expect(response.body.scan("BEGIN:VEVENT").size).to eq(3)
      end
    end
  end
end
