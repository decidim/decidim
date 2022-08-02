# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe SearchesController, type: :controller do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { create(:organization) }
    let(:component) { create(:component, organization:) }
    let(:resource) { create(:dummy_resource, component:) }

    before do
      request.env["decidim.current_organization"] = organization
      request.env["decidim.current_component"] = component
    end

    describe "GET /search" do
      context "when having resources with the term 'Great' in their content" do
        let!(:results) do
          now = Time.current
          [
            create(:searchable_resource, organization:, content_a: "Great proposal of mine", datetime: now + 1.second),
            create(:searchable_resource, organization:, content_a: "The greatest place of the world", datetime: now)
          ]
        end

        before do
          create(:searchable_resource, organization:, content_a: "I don't like groomming my dog.")
        end

        it "returns results with 'Great' in their content" do
          get :index, params: { term: "Great" }

          expect(assigns(:sections)).to have_key("Decidim::DummyResources::DummyResource")
          dummy_section = assigns(:sections)["Decidim::DummyResources::DummyResource"]
          expect(dummy_section[:count]).to eq 2
          expect(dummy_section[:results]).to match_array(results.map(&:resource))
          expect(assigns(:results_count)).to eq 2
        end
      end
    end

    context "when applying resource_type filter" do
      let(:search) { instance_dobule(Decidim::Search) }
      let(:resource_type) { "SomeResourceType" }

      before { allow(Decidim::Search).to receive(:call) }

      it "takes the resource_type filter into account" do
        expect(Decidim::Search).to receive(:call).with(any_args, hash_including(with_resource_type: resource_type), a_kind_of(Hash))

        get :index, params: { term: "Blues", "filter[with_resource_type]" => resource_type }
      end
    end

    context "when applying scope filter" do
      let(:search) { instance_dobule(Decidim::Search) }
      let(:scope_id) { "SomeScopeId" }

      before { allow(Decidim::Search).to receive(:call) }

      it "takes the scope filter into account" do
        expect(Decidim::Search).to receive(:call).with(any_args, hash_including(decidim_scope_id_eq: scope_id), a_kind_of(Hash))

        get :index, params: { term: "Blues", "filter[decidim_scope_id_eq]" => scope_id }
      end
    end

    context "when applying space state filter" do
      let(:search) { instance_dobule(Decidim::Search) }
      let(:space_state) { "SpaceState" }

      before { allow(Decidim::Search).to receive(:call) }

      it "takes the space filter into account" do
        expect(Decidim::Search).to receive(:call).with(any_args, hash_including(with_space_state: space_state), a_kind_of(Hash))

        get :index, params: { term: "Blues", "filter[with_space_state]" => space_state }
      end
    end
  end
end
