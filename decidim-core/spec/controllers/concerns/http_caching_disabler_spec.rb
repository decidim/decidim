# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Headers
    describe "HttpCachingDisabler" do
      let!(:organization) { create(:organization) }
      let!(:user) { create(:user, :confirmed, organization:) }

      controller do
        include Decidim::Headers::HttpCachingDisabler

        def show
          render plain: "Hello World"
        end
      end

      before do
        request.env["decidim.current_organization"] = organization
        routes.draw { get "show" => "anonymous#show" }
      end

      it "sets the appropriate headers" do
        get :show
        expect(response.headers["Cache-Control"]).to eq("no-cache, no-store")
        expect(response.headers["Pragma"]).to eq("no-cache")
        expect(response.headers["Expires"]).to eq("Fri, 01 Jan 1990 00:00:00 GMT")
      end
    end
  end
end
