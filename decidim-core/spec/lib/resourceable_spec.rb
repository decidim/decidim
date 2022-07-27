# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Resourceable do
    let(:resource) do
      build(:dummy_resource)
    end

    describe "linked_resources" do
      let(:participatory_process) { create(:participatory_process) }

      let!(:target_component) { create(:component, manifest_name: :dummy, participatory_space: participatory_process) }
      let!(:current_component) { create(:component, manifest_name: :dummy, participatory_space: participatory_process) }

      let!(:resource) { create(:dummy_resource, component: current_component) }
      let!(:target_resource) { create(:dummy_resource, component: target_component) }

      context "when linking to a resource" do
        let(:received_on_create) { {} }

        before do
          event_name = "decidim.resourceable.link-name.created"
          ActiveSupport::Notifications.subscribe event_name do |_name, _started, _finished, _unique_id, data|
            received_on_create.merge!(data)
          end
          resource.link_resources(target_resource, "link-name")
        end

        it "includes the linked resource" do
          expect(resource.linked_resources(:dummy, "link-name")).to include(target_resource)
        end

        it "sends an event to notify the linking happened" do
          payload = { from_type: "Decidim::DummyResources::DummyResource", from_id: resource.id, to_type: "Decidim::DummyResources::DummyResource", to_id: target_resource.id }
          expect(received_on_create[:this]).to eq(payload)
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
        context "when there are no component for the sibling" do
          it "returns a none relation" do
            expect(resource.sibling_scope(:foo)).to be_none
          end
        end

        context "when there are sibling components" do
          let(:participatory_process) { create(:participatory_process) }

          let!(:other_component) { create(:component, manifest_name: :dummy) }
          let!(:target_component) { create(:component, manifest_name: :dummy, participatory_space: participatory_process) }
          let!(:current_component) { create(:component, manifest_name: :dummy, participatory_space: participatory_process) }

          let!(:resource) { create(:dummy_resource, component: current_component) }
          let!(:target_resource) { create(:dummy_resource, component: target_component) }
          let!(:other_resource) { create(:dummy_resource, component: other_component) }

          it "returns a relation scoped to the sibling component" do
            expect(resource.sibling_scope(:dummy)).to include(target_resource)
            expect(resource.sibling_scope(:dummy)).not_to include(resource)
            expect(resource.sibling_scope(:dummy)).not_to include(other_resource)
          end
        end

        context "when the target component is unpublished" do
          let(:participatory_process) { create(:participatory_process) }

          let!(:resource) { create(:dummy_resource, component: current_component) }
          let!(:current_component) { create(:component, manifest_name: :dummy, participatory_space: participatory_process) }
          let!(:target_component) { create(:component, manifest_name: :dummy, participatory_space: participatory_process) }
          let!(:target_resource) { create(:dummy_resource, component: target_component) }

          before do
            target_component.unpublish!
          end

          it "doesn't return anything from that component" do
            expect(resource.sibling_scope(:dummy)).to be_empty
          end
        end

        context "when the target component is moderated" do
          let(:participatory_process) { create(:participatory_process) }

          let!(:resource) { create(:dummy_resource, component: current_component) }
          let!(:current_component) { create(:component, manifest_name: :dummy, participatory_space: participatory_process) }
          let!(:target_component) { create(:component, manifest_name: :dummy, participatory_space: participatory_process) }
          let!(:target_resource) { create(:dummy_resource, component: target_component) }
          let!(:moderation) { create(:moderation, reportable: target_resource, hidden_at: Time.current) }

          it "doesn't return anything from that component" do
            expect(resource.sibling_scope(:dummy)).to be_empty
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

      let(:proposals_component1) { create :component, manifest_name: "proposals" }
      let(:proposals_component2) { create :component, manifest_name: "proposals" }
      let(:meetings_component) { create :component, manifest_name: "meetings", participatory_space: proposals_component1.participatory_space }
      let(:dummy_component) { create :component, manifest_name: "dummy", participatory_space: proposals_component2.participatory_space }
      let(:proposal1) { create :proposal, component: proposals_component1 }
      let(:proposal2) { create :proposal, component: proposals_component2 }
      let(:meeting) { create :meeting, component: meetings_component }
      let(:dummy_resource) { create :dummy_resource, component: dummy_component }

      before do
        proposal1.link_resources([meeting], "proposals_from_meeting")
        proposal2.link_resources([dummy_resource], "included_proposals")
      end

      it "finds the linked classes for a given component" do
        expect(subject.linked_classes_for(proposals_component1)).to eq ["Decidim::Meetings::Meeting"]
      end
    end

    describe "#visible?" do
      subject { resource }

      context "when all hierarchy is visible" do
        before { subject.update(published_at: Time.current) }

        it { is_expected.to be_visible }
      end

      context "when participatory space is private" do
        before { subject.component.participatory_space.update(private_space: true) }

        it { is_expected.not_to be_visible }
      end

      context "when participatory space is unpublished" do
        before { subject.component.participatory_space.update(published_at: nil) }

        it { is_expected.not_to be_visible }
      end

      context "when component is NOT published" do
        before { subject.component.update(published_at: nil) }

        it { is_expected.not_to be_visible }
      end
    end

    describe "#resource_visible?" do
      subject { resource }

      context "when resource is not published" do
        before { subject.update(published_at: nil) }

        it { is_expected.not_to be_visible }
      end

      context "when resource is moderated" do
        let!(:resource) { create(:dummy_resource, :published) }
        let!(:moderation) { create(:moderation, :hidden, reportable: subject) }

        it { is_expected.not_to be_visible }
      end
    end
  end
end
