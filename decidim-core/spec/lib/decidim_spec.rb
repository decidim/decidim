# frozen_string_literal: true

require "spec_helper"

describe Decidim do
  it "has a version number" do
    expect(described_class.version).not_to be_nil
  end

  describe ".seed!" do
    it "actually seeds" do
      expect { described_class.seed! }.not_to raise_error
    end

    it "loads seeds for every engine" do
      decidim_railties = [
        double(load_seed: nil, class: double(name: "Decidim::EngineA")),
        double(load_seed: nil, class: double(name: "Decidim::EngineB"))
      ]

      other_railties = [
        double(load_seed: nil, class: double(name: "Something::EngineA")),
        double(load_seed: nil, class: double(name: "Something::EngineB"))
      ]

      expect(decidim_railties).to all(receive(:load_seed))
      expect(other_railties).not_to include(receive(:load_seed))

      manifests = [double(name: "Component A"), double(name: "Component B")]
      allow(described_class).to receive(:participatory_space_manifests).and_return(manifests)

      expect(manifests).to all(receive(:seed!).once)

      application = double(railties: (decidim_railties + other_railties))
      allow(Rails).to receive(:application).and_return application

      described_class.seed!
    end
  end

  describe ".component_manifests" do
    subject { described_class.component_manifests }

    it "returns the manifests sorted alphabetically" do
      components_name = subject.pluck(:name)
      expect(components_name).to eq(components_name.sort)
    end
  end

  describe ".module_installed?" do
    subject { described_class.module_installed?(mod) }

    context "with default configurations" do
      %w(
        accountability
        admin
        api
        assemblies
        blogs
        budgets
        comments
        core
        debates
        forms
        generators
        meetings
        pages
        participatory_processes
        proposals
        sortitions
        surveys
        system
        templates
        verifications
        conferences
        initiatives
        templates
      ).each do |decidim_gem|
        context decidim_gem do
          let(:mod) { decidim_gem }

          it { is_expected.to be(true) }
        end
      end
    end

    context "when the module is needed but does not define a module load file" do
      let(:mod) { :foo }

      before do
        allow(Decidim::DependencyResolver.instance).to receive(:needed?).with("decidim-#{mod}").and_return(true)
      end

      it "does not raise an exception and returns false" do
        expect { subject }.not_to raise_error
        expect(subject).to be(false)
      end
    end
  end
end
