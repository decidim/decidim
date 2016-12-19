require "spec_helper"

describe "Proposals feature" do
  let!(:feature) { create(:proposal_feature) }

  describe "on destroy" do
    context "when there are no proposals for the feature" do
      it "destroys the feature" do
        expect do
          Decidim::Admin::DestroyFeature.call(feature)
        end.to change { Decidim::Feature.count }.by(-1)

        expect(feature).to be_destroyed
      end
    end

    context "when there are proposals for the feature" do
      before do
        create(:proposal, feature: feature)
      end

      it "raises an error" do
        expect do
          Decidim::Admin::DestroyFeature.call(feature)
        end.to raise_error

        expect(feature).to_not be_destroyed
      end
    end
  end
end
