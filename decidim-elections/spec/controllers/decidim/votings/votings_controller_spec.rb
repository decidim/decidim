# frozen_string_literal: true

require "spec_helper"

describe Decidim::Votings::VotingsController do
  routes { Decidim::Votings::Engine.routes }

  let(:organization) { create(:organization) }
  let(:voting) { create(:voting, organization:) }

  before do
    request.env["decidim.current_organization"] = organization
  end

  describe "GET show" do
    context "when there is a voting" do
      it "can access it" do
        get :show, params: { slug: voting.slug }
        expect(subject).to render_template(:show)
        expect(flash[:alert]).to be_blank
        expect(controller.send(:current_participatory_space)).to eq voting
      end
    end

    context "when there is not a voting" do
      it "returns 404" do
        expect { get :show, params: { slug: "invalid-voting" } }
          .to raise_error(ActionController::RoutingError)
      end
    end
  end

  describe "GET elections_log" do
    context "when there is a voting" do
      it "can access it" do
        get :elections_log, params: { voting_slug: voting.slug }
        expect(subject).to render_template(:elections_log)
        expect(flash[:alert]).to be_blank
        expect(controller.send(:current_participatory_space)).to eq voting
      end
    end

    context "when there is not a voting" do
      it "returns 404" do
        expect { get :elections_log, params: { voting_slug: "invalid-voting" } }
          .to raise_error(ActionController::RoutingError)
      end
    end
  end
end
