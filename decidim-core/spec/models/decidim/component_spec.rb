# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Component do
    subject { component }

    let!(:organization) { create(:organization) }
    let(:component) { build(:component, manifest_name: "dummy", organization:) }

    it { is_expected.to be_valid }
    it { is_expected.to be_versioned }

    include_examples "publicable"
    include_examples "resourceable"
    include_examples "taxonomy settings"

    it "overwrites the log presenter" do
      expect(described_class.log_presenter_class_for(:foo))
        .to eq Decidim::AdminLog::ComponentPresenter
    end

    describe "default scope" do
      subject { described_class.all }

      it "orders the components by weight and by manifest name" do
        described_class.destroy_all

        component_b = create(:component, manifest_name: "proposals", weight: 0)
        component_c = create(:component, manifest_name: :dummy, weight: 2)
        component_a = create(:component, manifest_name: :dummy, weight: 0)

        expect(subject).to eq [component_a, component_b, component_c]
      end
    end

    describe ".for_organization" do
      subject { described_class.for_organization(organization:) }

      let!(:component) { create(:component, manifest_name: "dummy", organization:) }
      let!(:assembly_component) do
        create(:component, manifest_name: "dummy", organization:, participatory_space: create(:assembly, organization:))
      end
      let!(:other_component) { create(:component, manifest_name: "dummy", organization: other_organization) }
      let(:other_organization) { create(:organization) }

      it "returns the components belonging to the organization participatory spaces" do
        expect(subject).to include(component, assembly_component)
      end

      it "does not return components from other organizations" do
        expect(subject).not_to include(other_component)
      end

      it "does not load the organization participatory spaces into memory" do
        expect(organization).not_to receive(:participatory_spaces)

        subject.to_a
      end

      context "when a participatory space manifest already defines a projection" do
        let(:manifest) { Decidim.find_participatory_space_manifest(:participatory_processes) }
        let(:space_class) { manifest.model_class_name.constantize }

        before do
          allow(manifest).to receive(:participatory_spaces).and_return(
            ->(current_organization) { space_class.where(organization: current_organization).select(:id, :created_at) }
          )
        end

        it "only selects the id in the subquery" do
          expect(subject).to include(component)
        end
      end
    end

    describe "restricted_space?" do
      subject { component }

      let(:component) { create(:component, manifest_name: "another_dummy", participatory_space:) }

      context "when the component belongs to a restricted space" do
        let(:participatory_space) do
          create(:participatory_process, :restricted, organization:)
        end

        it "returns true" do
          expect(subject.restricted_space?).to be true
        end
      end

      context "when the component belongs to an open space" do
        let(:participatory_space) do
          create(:participatory_process, :open, organization:)
        end

        it "returns false" do
          expect(subject.restricted_space?).to be false
        end
      end

      context "when the component belongs to a transparent space" do
        let(:participatory_space) do
          create(:assembly, :transparent, organization:)
        end

        it "returns false" do
          expect(subject.restricted_space?).to be false
        end
      end
    end
  end
end
