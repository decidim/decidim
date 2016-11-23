require "spec_helper"

module Decidim
  module Admin
    describe DestroyFeature do
      let!(:feature) { create(:feature) }
      let!(:components) { create_list(:component, 3, feature: feature) }
      subject { described_class.new(feature) }

      context "when everything is ok" do
        it "destroys the feature" do
          subject.call
          expect(Feature.where(id: feature.id)).to_not exist
        end

        it "destroys all its components" do
          components.each do |component|
            expect(DestroyComponent).to receive(:call).with(component)
          end

          subject.call

          expect(feature).to_not be_persisted
        end
      end
    end
  end
end
