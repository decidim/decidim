# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe DestroyFeature do
    subject { described_class.new(feature) }

    let!(:feature) { create(:feature) }

    context "when everything is ok" do
      it "destroys the feature" do
        subject.call
        expect(Decidim::Feature.where(id: feature.id)).not_to exist
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
