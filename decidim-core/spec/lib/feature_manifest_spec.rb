require "spec_helper"

module Decidim
  describe FeatureManifest do
    subject { described_class.new }

    describe "component" do
      it "exposes a DSL to create a component" do
        components = {}

        subject.component(:foo) do |component|
          components[:foo] = component
        end

        subject.component(:bar) do |component|
          components[:bar] = component
        end

        expect(components[:foo]).to be_kind_of(ComponentManifest)
        expect(components[:foo].name).to eq(:foo)

        expect(components[:bar]).to be_kind_of(ComponentManifest)
        expect(components[:bar].name).to eq(:bar)

        expect(subject.components).to include(components[:foo], components[:bar])
      end
    end
  end
end
