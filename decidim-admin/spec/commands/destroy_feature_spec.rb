# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe DestroyFeature do
    subject { described_class.new(feature, current_user) }

    let!(:feature) { create(:feature) }
    let!(:current_user) { create(:user, organization: feature.participatory_space.organization) }

    context "when everything is ok" do
      it "destroys the feature" do
        subject.call
        expect(Decidim::Feature.where(id: feature.id)).not_to exist
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with("delete", feature, current_user)
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)

        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
        expect(action_log.version.event).to eq "destroy"
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
