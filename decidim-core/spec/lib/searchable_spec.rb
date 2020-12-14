# frozen_string_literal: true

require "spec_helper"

module Decidim
  COMMON_ID = 666

  describe Searchable do
    let(:component) { create(:component, manifest_name: "dummy") }

    context "when having searchables of different kinds indexed" do
      let(:organization_1) { create(:organization) }
      let(:component_1) { create(:component, organization: organization_1) }
      let(:organization_2) { create(:organization) }
      let(:component_2) { create(:component, organization: organization_2) }

      let!(:dummy_resource_1) do
        Decidim::DummyResources::DummyResource.create!(
          id: COMMON_ID,
          component: component_1,
          published_at: Time.current,
          author: organization_1
        )
      end
      let!(:dummy_resource_2) do
        Decidim::DummyResources::DummyResource.create!(
          id: COMMON_ID + 1,
          component: component_2,
          published_at: Time.current,
          author: organization_2
        )
      end
      let!(:user_1) { create(:user, id: COMMON_ID, organization: organization_1) }
      let!(:user_2) { create(:user, id: COMMON_ID + 1, organization: organization_2) }

      it "each searchable should link to its own searchable_resources" do
        org = user_1.organization
        num_locales = org.available_locales.size
        expect(dummy_resource_1.searchable_resources.by_organization(org.id).pluck(:resource_id, :resource_type)).to eq([[COMMON_ID, "Decidim::DummyResources::DummyResource"]] * num_locales)
        expect(user_1.searchable_resources.by_organization(org.id).pluck(:resource_id, :resource_type)).to eq([[COMMON_ID, "Decidim::User"]] * num_locales)
      end
    end

    describe ".order_by_id_list" do
      subject { Decidim::DummyResources::DummyResource.order_by_id_list(ids) }

      context "when no ids is nil" do
        let(:ids) { nil }

        it { is_expected.to eq ApplicationRecord.none }
      end

      context "when no ids is an empty list" do
        let(:ids) { [] }

        it { is_expected.to eq ApplicationRecord.none }
      end

      context "with a list of ids" do
        let(:resource1) { create :dummy_resource }
        let(:resource2) { create :dummy_resource }
        let(:ids) { [resource2.id, resource1.id] }

        it { is_expected.to eq [resource2, resource1] }
      end
    end

    describe "#try_update_index_for_search_resource" do
      let!(:participatory_process) { create(:participatory_process) }

      context "when searchable doesn't have component" do
        it "enqueues the job when participatory process is updated" do
          expect(Decidim::FindAndUpdateDescendantsJob).to receive(:perform_later).with(participatory_process)

          participatory_process.update!(published_at: nil)
        end
      end

      context "when searchable has a component" do
        let!(:proposal_component) { create(:proposal_component, participatory_space: participatory_process) }
        let!(:resource) { create(:proposal, :official, component: proposal_component) }

        it "enqueues the job when participatory process is updated" do
          expect(Decidim::FindAndUpdateDescendantsJob).to receive(:perform_later).with(participatory_process)

          participatory_process.update!(published_at: nil)
        end
      end

      context "when class is not a searchable resource" do
        before do
          allow(Decidim::ParticipatoryProcess).to receive(:searchable_resource?).with(participatory_process).and_return(false)
        end

        it "doesn't enqueues the job" do
          expect(Decidim::FindAndUpdateDescendantsJob).not_to receive(:perform_later)

          participatory_process.update!(published_at: nil)
        end
      end
    end
  end
end
