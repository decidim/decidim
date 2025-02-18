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

    describe "private_non_transparent_space?" do
      subject { component }

      let(:component) { create(:component, manifest_name: "another_dummy", participatory_space:) }

      context "when the component belongs to a private space" do
        let(:participatory_space) do
          create(:participatory_process, organization:, private_space: true)
        end

        it "returns true" do
          expect(subject.private_non_transparent_space?).to be true
        end
      end

      context "when the component belongs to a non-private space" do
        let(:participatory_space) do
          create(:participatory_process, organization:, private_space: false)
        end

        it "returns false" do
          expect(subject.private_non_transparent_space?).to be false
        end
      end

      context "when the component belongs to a private transparent space" do
        let(:participatory_space) do
          create(:assembly, organization:, private_space: false, is_transparent: true)
        end

        it "returns false" do
          expect(subject.private_non_transparent_space?).to be false
        end
      end
    end
  end
end
