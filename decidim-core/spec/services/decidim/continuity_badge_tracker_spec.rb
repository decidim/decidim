# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ContinuityBadgeTracker do
    let(:user) { create(:user) }
    let(:subject) { described_class.new(user) }

    context "when tracking for the first time" do
      let(:date) { Time.zone.today }

      before do
        subject.track!(date)
      end

      it "sets the date and streak to 1" do
        status = ContinuityBadgeStatus.find_by(subject: user)
        expect(status).to have_attributes(
          current_streak: 1,
          last_session_at: date
        )
      end

      it "keeps the badge score at 0" do
        expect(Decidim::Gamification.status_for(user, :continuity).score).to eq(0)
      end
    end

    context "when tracking on the second consecutive day" do
      let(:date) { Time.zone.today }

      before do
        ContinuityBadgeStatus.create!(
          subject: user,
          last_session_at: date - 1.day,
          current_streak: 1
        )

        subject.track!(date)
      end

      it "sets the date and streak to 2" do
        status = ContinuityBadgeStatus.find_by(subject: user)
        expect(status).to have_attributes(
          current_streak: 2,
          last_session_at: date
        )
      end

      it "sets the badge score to 2" do
        expect(Decidim::Gamification.status_for(user, :continuity).score).to eq(2)
      end
    end

    context "when tracking for the second time on the same day" do
      let(:date) { Time.zone.today }
      let(:streak) { 10 }

      before do
        ContinuityBadgeStatus.create!(
          subject: user,
          last_session_at: date,
          current_streak: streak
        )

        subject.track!(date)
      end

      it "keeps the same values" do
        status = ContinuityBadgeStatus.find_by(subject: user)
        expect(status).to have_attributes(
          current_streak: streak,
          last_session_at: date
        )
      end

      it "keeps the badge score at 10" do
        expect(Decidim::Gamification.status_for(user, :continuity).score).to eq(10)
      end
    end

    context "when tracking the next day" do
      let(:date) { Time.zone.today }
      let(:streak) { 10 }

      before do
        ContinuityBadgeStatus.create!(
          subject: user,
          last_session_at: date - 1.day,
          current_streak: streak
        )

        subject.track!(date)
      end

      it "increases the current streak" do
        status = ContinuityBadgeStatus.find_by(subject: user)
        expect(status).to have_attributes(
          current_streak: streak + 1,
          last_session_at: date
        )
      end

      it "sets the badge score at 11" do
        expect(Decidim::Gamification.status_for(user, :continuity).score).to eq(11)
      end
    end

    context "when not active for more than one day" do
      let(:date) { Time.zone.today }
      let(:streak) { 10 }

      before do
        ContinuityBadgeStatus.create!(
          subject: user,
          last_session_at: date - 2.days,
          current_streak: streak
        )

        Decidim::Gamification.set_score(user, :continuity, streak)

        subject.track!(date)
      end

      it "sets the current streak to 0" do
        status = ContinuityBadgeStatus.find_by(subject: user)
        expect(status).to have_attributes(
          current_streak: 1,
          last_session_at: date
        )
      end

      it "keeps the badge score at 10" do
        expect(Decidim::Gamification.status_for(user, :continuity).score).to eq(10)
      end
    end
  end
end
