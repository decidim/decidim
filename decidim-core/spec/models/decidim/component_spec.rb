# frozen_string_literal: true
require "spec_helper"

module Decidim
  describe Component, type: :model do
    subject { described_class.new }

    describe "manifest" do
      it "finds the manifest for its own type" do
        subject.component_type = "dummy"
        expect(subject.manifest).to eq(Decidim.find_component_manifest("dummy"))
      end

      it "returns nil if no manifest is found" do
        subject.component_type = "invalid_manifest_name"
        expect(subject.manifest).to be_nil
      end
    end

    describe "manifest=" do
      it "sets an appropiate component_type" do
        subject.manifest = Decidim.find_component_manifest("dummy")
        expect(subject.component_type).to eq("dummy")
      end
    end

    describe "validations" do
      let(:step) { create(:participatory_process_step) }
      let(:participatory_process) { step.participatory_process }
      let(:feature) do
        create(
          :feature,
          feature_type: "dummy",
          participatory_process: participatory_process
        )
      end

      let(:manifest) { Decidim.find_component_manifest("dummy") }

      before do
        subject.step = step
        subject.manifest = manifest
      end

      context "when the component manifest belongs to the feature" do
        it "is valid" do
          subject.feature = feature
          subject.manifest = manifest
          expect(subject).to be_valid
        end
      end

      context "when the component doesn't belong to the manifest's feature" do
        let(:feature) do
          create(
            :feature,
            feature_type: "invalid_feature",
            participatory_process: participatory_process
          )
        end

        it "is invalid" do
          subject.feature = feature
          expect(subject).to_not be_valid
        end
      end
    end
  end
end
