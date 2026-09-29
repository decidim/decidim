# frozen_string_literal: true

require "spec_helper"

describe "rake decidim:upgrade:align_followers_badge_scores", type: :task do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization:) }
  let(:follower1) { create(:user, organization:) }
  let(:follower2) { create(:user, organization:) }

  before do
    create(:follow, followable: user, user: follower1)
    create(:follow, followable: user, user: follower2)
  end

  context "when the badge score is out of sync" do
    before do
      Decidim::Gamification::BadgeScore.find_or_create_by!(
        user:,
        badge_name: "followers"
      ).update!(value: 0)
    end

    it "calls set_score (not update_columns) to trigger badge notifications" do
      expect(Decidim::Gamification).to receive(:set_score).with(user, :followers, 2)
      task.execute
    end

    it "updates the badge score to match the real follower count" do
      allow(Decidim::Gamification).to receive(:set_score).and_call_original
      expect { task.execute }.to change {
        Decidim::Gamification::BadgeScore.find_by(
          user:,
          badge_name: "followers"
        ).value
      }.from(0).to(2)
    end

    it "outputs the fixed count" do
      expect { task.execute }.to output(/Fixed:\s+1/).to_stdout
    end
  end

  context "when the badge score is already correct" do
    before do
      Decidim::Gamification::BadgeScore.find_or_create_by!(
        user:,
        badge_name: "followers"
      ).update!(value: 2)
    end

    it "does not call set_score" do
      expect(Decidim::Gamification).not_to receive(:set_score)
      task.execute
    end

    it "does not change the badge score" do
      expect do
        task.execute
      end.not_to(change do
        Decidim::Gamification::BadgeScore.find_by(
          user:,
          badge_name: "followers"
        ).value
      end)
    end

    it "outputs the skipped count" do
      expect { task.execute }.to output(/Skipped:\s+1/).to_stdout
    end
  end

  context "when there are no followers badge scores" do
    it "completes without error and reports zero fixed" do
      expect { task.execute }.to output(/Fixed:\s+0/).to_stdout
    end
  end
end
