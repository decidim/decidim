# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe SearchesController, type: :controller do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { create(:organization) }
    let(:feature) { create(:feature, organization: organization) }
    let(:resource) { create(:dummy_resource, feature: feature) }

    before do
      request.env["decidim.current_organization"] = organization
      request.env["decidim.current_feature"] = feature
    end

    describe "GET /search" do
      context "when having resources with the term 'Great' in their content" do
        let!(:results) {
          [create(:searchable_rsrc, content_a: 'Great proposal of mine'),
            create(:searchable_rsrc, content_a: 'The great-est place of the world')]
        }
        before do
          create(:searchable_rsrc, content_a: "I don't like groomming my dog.")
        end
        it "should return results with 'Great' in their content" do
          get :index, params: {term: 'Great'}

          expect(assigns(:results)).to eq(results)
        end
      end
    end
  end
end
