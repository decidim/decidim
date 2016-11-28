require "spec_helper"

module Decidim
  describe FeatureManifest do
    subject { described_class.new }

    describe "component" do
      it "exposes a DSL to create a component" do
        manifests = {}

        subject.component(:foo) do |component|
          manifests[:foo] = component
        end

        subject.component(:bar) do |component|
          manifests[:bar] = component
        end

        expect(manifests[:foo]).to be_kind_of(ComponentManifest)
        expect(manifests[:foo].name).to eq(:foo)

        expect(manifests[:bar]).to be_kind_of(ComponentManifest)
        expect(manifests[:bar].name).to eq(:bar)

        expect(subject.component_manifests).to include(manifests[:foo], manifests[:bar])
      end
    end

    describe "seed" do
      it "registers a block of seeds to be run on development" do
        data = {}
        subject.seeds do
          data[:foo] = :bar
        end

        subject.seed!

        expect(data[:foo]).to eq(:bar)
      end
    end
  end
end
