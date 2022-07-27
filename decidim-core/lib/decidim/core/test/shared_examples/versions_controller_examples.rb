# frozen_string_literal: true

require "spec_helper"

shared_examples "versions controller" do
  let(:base_params) do
    if resource.is_a?(Decidim::Participable)
      { "#{resource.model_name.singular_route_key}_slug".to_sym => resource.slug }
    else
      { "#{resource.model_name.singular_route_key}_id".to_sym => resource.id }
    end
  end

  before do
    request.env["decidim.current_organization"] = resource.organization

    if resource.is_a?(Decidim::HasComponent)
      request.env["decidim.current_participatory_space"] = resource.participatory_space
      request.env["decidim.current_component"] = resource.component
    end
  end

  describe "GET show" do
    context "with an existing version" do
      it "returns a HTTP 200" do
        get :show, params: base_params.merge(id: 1)

        expect(response).to have_http_status(:ok)
      end
    end

    context "when the resource does not exist" do
      it "raises a routing error" do
        expect do
          get :show, params: base_params.merge(id: 999_999_999)
        end.to raise_error(ActionController::RoutingError)
      end
    end
  end
end
