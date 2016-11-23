require "spec_helper"

module Decidim
  module Admin
    describe DestroyComponent do
      let(:component) { create(:component) }
      let(:manifest) { component.feature.manifest.components.first }

      subject { described_class.new(component) }

      before(:each) { manifest.reset_hooks! }
      after(:each) { manifest.reset_hooks! }

      context "when everything is ok" do
        it "destroys the component" do
          subject.call
          expect(Component.where(id: component.id)).to_not exist
        end

        it "fires the hooks" do
          results = {}

          manifest.on(:destroy) do |component|
            results[:component] = component
          end

          subject.call

          component = results[:component]
          expect(component.id).to eq(component.id)
          expect(component).to_not be_persisted
        end
      end
    end
  end
end
