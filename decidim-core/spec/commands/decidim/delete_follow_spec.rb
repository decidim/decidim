# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe DeleteFollow do
    let!(:organization) { create(:organization) }
    let!(:user1) { create(:user, organization:) }
    let!(:user2) { create(:user, organization:) }
    let!(:follow) { create(:follow, user: user1, followable: user2) }

    let(:form) { double(follow:, invalid?: false) }

    it "destroys a follow" do
      expect { described_class.new(form, user1).call }.to broadcast(:ok)

      expect(user2.reload.followers).not_to include(user1)
      expect(user2.follows_count).to eq(0)
    end

    describe "gamification" do
      before do
        Decidim::Gamification.set_score(user1, :followers, 10)
        Decidim::Gamification.set_score(user2, :followers, 10)
      end

      it "decrements the user's score" do
        described_class.new(form, user1).call

        expect(Decidim::Gamification.status_for(user1, :followers).score).to eq(10)
        expect(Decidim::Gamification.status_for(user2, :followers).score).to eq(9)
      end
    end
  end
end
