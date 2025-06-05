# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe "decidim/verifications/authorizations/new" do
    let(:handler) do
      DummyAuthorizationHandler.new({})
    end
    let(:organization) { double(cta_button_path: "/") }
    let(:user) { create(:user, :confirmed) }
    let(:onboarding_manager) { Decidim::OnboardingManager.new(user) }

    before do
      view.extend AuthorizationFormHelper
      view.extend DecidimFormHelper

      allow(view).to receive(:current_organization).and_return(organization)
      allow(view).to receive(:handler).and_return(handler)
      allow(view).to receive(:params).and_return(handler: "dummy_authorization_handler")
      allow(view).to receive(:authorizations_path).and_return("/authorizations")
      allow(view).to receive(:current_user).and_return(user)
      allow(view).to receive(:authorizations_back_path).and_return("/authorizations")
      allow(view).to receive(:stored_location).and_return("/processes")
      allow(view).to receive(:redirect_url).and_return("/")
      allow(view).to receive(:onboarding_manager).and_return(onboarding_manager)
    end

    it "renders the form from the partial" do
      expect(render).to have_css("[data-partial-demo]")
    end

    it "renders the button separately" do
      expect(render).to have_tag("button[type=submit]", count: 1)
    end

    context "when there is not a partial to render the form" do
      before do
        allow(handler).to receive(:to_partial_path).and_return("nonexistent_partial")
      end

      it "renders the form without the partial" do
        expect(render).to have_no_css("[data-partial-demo]")
      end
    end
  end
end
