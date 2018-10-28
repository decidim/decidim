# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe SearchesController, type: :controller do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { create(:organization) }
    let(:component) { create(:component, organization: organization) }
    let(:resource) { create(:dummy_resource, component: component) }

    before do
      request.env["decidim.current_organization"] = organization
      request.env["decidim.current_component"] = component
    end

    describe "GET /search" do
      context "when having resources with the term 'Great' in their content" do
        let!(:results) do
          now = Time.current
          [create(:searchable_resource, organization: organization, content_a: "Great proposal of mine", datetime: now + 1.second),
           create(:searchable_resource, organization: organization, content_a: "The great-est place of the world", datetime: now)]
        end

        before do
          create(:searchable_resource, organization: organization, content_a: "I don't like groomming my dog.")
        end

        it "returns results with 'Great' in their content" do
          get :index, params: { term: "Great" }

          expect(assigns(:results)).to eq(results)
        end
      end
    end

    context "when applying resource_type filter" do
      let(:search) { instance_dobule(Decidim::Search) }
      let(:resource_type) { "SomeResourceType" }

      before { allow(Decidim::Search).to receive(:call) }

      it "takes the resource_type filter into account" do
        expect(Decidim::Search).to receive(:call).with(any_args, hash_including(resource_type: resource_type))

        get :index, params: { term: "Blues", "filter[resource_type]" => resource_type }
      end
    end

    context "when applying scope filter" do
      let(:search) { instance_dobule(Decidim::Search) }
      let(:scope_id) { "SomeScopeId" }

      before { allow(Decidim::Search).to receive(:call) }

      it "takes the scope filter into account" do
        expect(Decidim::Search).to receive(:call).with(any_args, hash_including(scope_id: scope_id))

        get :index, params: { term: "Blues", "filter[scope_id]" => scope_id }
      end
    end
  end
end
