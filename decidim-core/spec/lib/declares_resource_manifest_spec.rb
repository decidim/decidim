# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe DeclaresResourceManifest do
    subject do
      Decidim::DummyResources::DummyResource.include(Decidim::DeclaresResourceManifest)
      create(:dummy_resource)
    end

    before do
      subject.component.manifest.register_resource do |resource|
        resource.model_class_name = Decidim::DummyResources::DummyResource.name
      end
    end

    describe "resource_manifest" do
      it "returns the resource_manifest" do
        expect(subject.resource_manifest).to eq(subject.component.manifest.resource_manifests.last)
      end
    end
  end
end
