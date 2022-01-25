# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe OfflineController, type: :controller do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { create(:organization) }

    before do
      request.env["decidim.current_organization"] = organization
    end

    describe "GET /offline" do
      it "returns the offline content" do
        get :show

        expect(response).to be_successful
      end
    end
  end
end
