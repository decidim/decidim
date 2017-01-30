require "spec_helper"

module Decidim
  describe Resourceable do
    let(:resource) do
      build(:dummy_resource)
    end

    describe "linked_resources" do
      let(:participatory_process) { create(:participatory_process) }

      let!(:target_feature) { create(:feature, manifest_name: :dummy, participatory_process: participatory_process) }
      let!(:current_feature) { create(:feature, manifest_name: :dummy, participatory_process: participatory_process) }

      let!(:resource) { create(:dummy_resource, feature: current_feature) }
      let!(:target_resource) { create(:dummy_resource, feature: target_feature) }

      context "when I'm linking to a resource" do
        before do
          resource.link_resources(target_resource, "link-name")
        end

        it "includes the linked resource" do
          expect(resource.linked_resources(:dummy, "link-name")).to include(target_resource)
        end
      end

      context "when a resource links to me" do
        before do
          target_resource.link_resources(resource, "link-name")
        end

        it "includes the origin resource" do
          expect(resource.linked_resources(:dummy, "link-name")).to include(target_resource)
        end
      end
    end

    describe "sibling_scope" do
      context "when there's a resource manifest" do
        context "when there are no feature for the sibling" do
          it "returns a none relation" do
            expect(resource.sibling_scope(:foo)).to be_none
          end
        end

        context "when there are sibling features" do
          let(:participatory_process) { create(:participatory_process) }

          let!(:other_feature) { create(:feature, manifest_name: :dummy) }
          let!(:target_feature) { create(:feature, manifest_name: :dummy, participatory_process: participatory_process) }
          let!(:current_feature) { create(:feature, manifest_name: :dummy, participatory_process: participatory_process) }

          let!(:resource) { create(:dummy_resource, feature: current_feature) }
          let!(:target_resource) { create(:dummy_resource, feature: target_feature) }
          let!(:other_resource) { create(:dummy_resource, feature: other_feature) }

          it "returns a relation scoped to the sibling feature" do
            expect(resource.sibling_scope(:dummy)).to include(target_resource)
            expect(resource.sibling_scope(:dummy)).not_to include(resource)
            expect(resource.sibling_scope(:dummy)).not_to include(other_resource)
          end
        end
      end

      context "when there's no resource manifest" do
        it "returns a none relation" do
          expect(resource.sibling_scope(:foo)).to be_none
        end
      end
    end

    describe "resource_manifest" do
      it "finds the resource manifest for the model" do
        manifest = resource.class.resource_manifest
        expect(manifest).to be_kind_of(Decidim::ResourceManifest)
        expect(manifest.model_class).to eq(resource.class)
      end
    end
  end
end
