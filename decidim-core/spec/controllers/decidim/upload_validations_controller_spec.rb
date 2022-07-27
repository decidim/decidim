# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UploadValidationsController, type: :controller do
    routes { Decidim::Core::Engine.routes }

    let(:params) do
      {
        resource_class:,
        property:,
        blob:,
        form_class:
      }
    end

    let(:resource_class) { "Decidim::DummyResources::DummyResource" }
    let(:property) { "avatar" }
    let(:blob) { upload_test_file(Decidim::Dev.test_file("city.jpeg", "image/jpeg")) }
    let(:form_class) { "Decidim::DummyResources::DummyForm" }

    let(:parsed_response) { JSON.parse(response.body) }

    describe "#create" do
      it "validates" do
        post :create, params: params

        expect(response.status).to eq(200)
        expect(parsed_response).to eq([])
      end
    end
  end
end
