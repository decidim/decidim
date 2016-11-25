require "spec_helper"

module Decidim
  module Admin
    describe DestroyComponent do
      let(:component) { create(:component) }
      let(:manifest) { component.feature.manifest.component_manifests.first }

      subject { described_class.new(component) }

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
