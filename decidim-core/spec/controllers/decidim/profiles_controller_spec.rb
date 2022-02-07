# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ProfilesController, type: :controller do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { create(:organization) }
    let!(:user) { create(:user, nickname: "nick", organization: organization) }

    before do
      request.env["decidim.current_organization"] = organization
    end

    describe "#badges" do
      context "with an user with uppercase" do
        it "returns the lowercased user" do
          get :badges, params: { nickname: "Nick" }
          expect(response).to render_template(:show)
        end
      end
    end
  end
end
