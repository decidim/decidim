# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::CalendarsController do
  routes { Decidim::Meetings::Engine.routes }

  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let(:meeting_component) { create(:meeting_component, :with_creation_enabled, participatory_space: participatory_process) }
  let!(:meetings) do
    [].tap do |list|
      list << create(:meeting, :published, :upcoming, title: { en: "First meeting" }, attending_organizations: "Decidim", component: meeting_component)
      list << create(:meeting, :published, :upcoming, title: { en: "Second meeting" }, component: meeting_component)
      list << create(:meeting, :published, :upcoming, title: { en: "Third meeting" }, component: meeting_component)
    end
  end

  before do
    request.env["decidim.current_organization"] = organization
  end

  describe "#show" do
    render_views

    let(:params) do
      {
        participatory_process_slug: participatory_process.slug,
        component_id: meeting_component.id,
        filter: filter_params
      }
    end
    let(:filter_params) { {} }

    before do
      request.env["decidim.current_participatory_space"] = participatory_process
      request.env["decidim.current_component"] = meeting_component
      get :show, params:
    end

    it { expect(response).to have_http_status(:success) }

    context "with the component parameters" do
      let(:filter_params) { { search_text_cont: "First meeting" } }

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
