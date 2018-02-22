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
          [create(:searchable_rsrc, organization: organization, content_a: 'Great proposal of mine'),
            create(:searchable_rsrc, organization: organization, content_a: 'The great-est place of the world')]
        }
        before do
          create(:searchable_rsrc, organization: organization, content_a: "I don't like groomming my dog.")
        end
        it "should return results with 'Great' in their content" do
          get :index, params: {term: 'Great'}

          expect(assigns(:results)).to eq(results)
        end
      end
    end
    context "when applying filters" do
      let(:search) { instance_dobule(Decidim::Search) }
      let(:resource_type) { "SomeResourceType" }
      before do
        allow(Decidim::Search).to receive(:call)
      end
      it "should take the filters into account" do
        expect(Decidim::Search).to receive(:call).with(any_args, {"resource_type" => resource_type})

        get :index, params: {term: 'Blues', "filter[resource_type]" => resource_type}
      end
    end
  end
end
