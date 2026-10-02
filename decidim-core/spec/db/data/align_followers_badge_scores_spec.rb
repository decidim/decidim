# frozen_string_literal: true

require "spec_helper"

require "./db/data/20260930112134_align_followers_badge_scores"

describe AlignFollowersBadgeScores do
  let(:migrator) do
    described_class.new.tap do |migration|
      migration.verbose = false
    end
  end

  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization:) }
  let(:follower1) { create(:user, organization:) }
  let(:follower2) { create(:user, organization:) }

  before do
    create(:follow, followable: user, user: follower1)
    create(:follow, followable: user, user: follower2)
  end

  describe "#up" do
    context "when the badge score is out of sync" do
      let!(:badge_score) do
        Decidim::Gamification::BadgeScore.find_or_create_by!(
          user:,
          badge_name: "followers"
        ).tap do |score|
          score.update!(value: 0)
        end
      end

      it "uses set_score to recalculate the followers badge score" do
        allow(Decidim::Gamification).to receive(:set_score).and_call_original

        migrator.migrate(:up)

        expect(Decidim::Gamification)
          .to have_received(:set_score)
          .with(user, badge_score.badge_name, 2)
      end

      it "updates the badge score to match the actual follower count" do
        expect { migrator.migrate(:up) }
          .to change { badge_score.reload.value }
          .from(0)
          .to(2)
      end
    end

    context "when the badge score is already correct" do
      let!(:badge_score) do
        score = Decidim::Gamification::BadgeScore.find_or_create_by!(
          user:,
          badge_name: "followers"
        )
        score.update!(value: 2)
        score
      end

      it "keeps the badge score unchanged" do
        expect { migrator.migrate(:up) }
          .not_to(change { badge_score.reload.value })
      end
    end

    context "when the followers badge is not available" do
      before do
        allow(Decidim::Gamification)
          .to receive(:find_badge)
          .with(:followers)
          .and_return(nil)
      end

      it "completes without an error" do
        expect { migrator.migrate(:up) }.not_to raise_error
      end

      it "does not recalculate any badge scores" do
        expect(Decidim::Gamification).not_to receive(:set_score)

        migrator.migrate(:up)
      end
    end
  end

  describe "#down" do
    it "raises ActiveRecord::IrreversibleMigration" do
      expect { migrator.migrate(:down) }
        .to raise_error(ActiveRecord::IrreversibleMigration)
    end
  end
end
