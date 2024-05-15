# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe "ActionAuthorization", type: :controller do
    let!(:organization) { create(:organization) }
    let(:component) { create(:dummy_component, organization:) }
    let(:resource) { create(:dummy_resource, component:) }
    let(:permissions_holder) { nil }

    controller do
      include Decidim::ActionAuthorization

      def show
        render plain: action_authorization_cache_key("show", resource, permissions_holder)
      end
    end

    before do
      request.env["decidim.current_organization"] = organization
      routes.draw { get "show" => "anonymous#show" }

      allow(controller).to receive(:current_component).and_return(component)
      allow(controller).to receive(:resource).and_return(resource)
      allow(controller).to receive(:permissions_holder).and_return(permissions_holder)
    end

    describe "#action_authorized_to" do
      it "renders the cache key" do
        get :show
        expect(response.body).to eq("show-#{component.id}")
      end

      context "with resource permissions" do
        let(:permissions) { double }

        before do
          allow(resource).to receive(:permissions).and_return(permissions)
        end

        it "renders the cache key" do
          get :show
          expect(response.body).to eq("show-#{component.id}-dummy-#{resource.id}")
        end
      end

      context "with permissions holder" do
        let(:permissions_holder) { organization }

        it "renders the cache key" do
          get :show
          expect(response.body).to eq("show-Decidim::Organization-#{organization.id}-dummy-#{resource.id}")
        end

        context "and without resource" do
          let(:resource) { nil }

          it "renders the cache key" do
            get :show
            expect(response.body).to eq("show-Decidim::Organization-#{organization.id}")
          end
        end
      end
    end
  end
end
