# frozen_string_literal: true

require "spec_helper"

describe "followers badge" do
  let(:organization) { create(:organization) }

  describe "reset" do
    it "resets the score to the amount of followers of a user" do
      user = create(:user, organization:)
      users = create_list(:user, 5, organization:)

      users.each do |follower|
        create(:follow, user: follower, followable: user)
      end

      Decidim::Gamification.reset_badges(Decidim::User.where(id: user.id))
      expect(Decidim::Gamification.status_for(user, :followers).score).to eq(5)
    end
  end
end
