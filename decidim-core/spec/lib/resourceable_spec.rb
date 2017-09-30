# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Resourceable do
    let(:resource) do
      build(:dummy_resource)
    end

    describe "linked_resources" do
      let(:participatory_process) { create(:participatory_process) }

      let!(:target_feature) { create(:feature, manifest_name: :dummy, participatory_space: participatory_process) }
      let!(:current_feature) { create(:feature, manifest_name: :dummy, participatory_space: participatory_process) }

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
          let!(:target_feature) { create(:feature, manifest_name: :dummy, participatory_space: participatory_process) }
          let!(:current_feature) { create(:feature, manifest_name: :dummy, participatory_space: participatory_process) }

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

    describe "#linked_classes_for" do
      subject { Decidim::Proposals::Proposal }

      let(:proposals_feature_1) { create :feature, manifest_name: "proposals" }
      let(:proposals_feature_2) { create :feature, manifest_name: "proposals" }
      let(:meetings_feature) { create :feature, manifest_name: "meetings", participatory_space: proposals_feature_1.participatory_space }
      let(:dummy_feature) { create :feature, manifest_name: "dummy", participatory_space: proposals_feature_2.participatory_space }
      let(:proposal_1) { create :proposal, feature: proposals_feature_1 }
      let(:proposal_2) { create :proposal, feature: proposals_feature_2 }
      let(:meeting) { create :meeting, feature: meetings_feature }
      let(:dummy_resource) { create :dummy_resource, feature: dummy_feature }

      before do
        proposal_1.link_resources([meeting], "proposals_from_meeting")
        proposal_2.link_resources([dummy_resource], "included_proposals")
      end

      it "finds the linked classes for a given feature" do
        expect(subject.linked_classes_for(proposals_feature_1)).to eq ["Decidim::Meetings::Meeting"]
      end
    end
  end
end
