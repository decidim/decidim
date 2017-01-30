require "spec_helper"

module Decidim
  module Admin
    describe DestroyFeature do
      let!(:feature) { create(:feature) }
      subject { described_class.new(feature) }

      context "when everything is ok" do
        it "destroys the feature" do
          subject.call
          expect(Feature.where(id: feature.id)).not_to exist
        end

        it "fires the hooks" do
          results = {}

          feature.manifest.on(:destroy) do |feature|
            results[:feature] = feature
          end

          subject.call

          feature = results[:feature]
          expect(feature.id).to eq(feature.id)
          expect(feature).not_to be_persisted
        end
      end
    end
  end
end
