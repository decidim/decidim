# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe CreateFollow do
    let!(:organization) { create(:organization) }
    let!(:user1) { create(:user, organization:) }
    let!(:user2) { create(:user, organization:) }

    let(:form) { double(followable: user2, invalid?: false) }

    it "creates a follow" do
      expect { described_class.new(form, user1).call }.to broadcast(:ok)
      expect(user2.reload.followers).to include(user1)
      expect(user2.follows_count).to eq(1)
    end

    it "increments the user's score" do
      described_class.new(form, user1).call

      expect(Decidim::Gamification.status_for(user1, :followers).score).to eq(0)
      expect(Decidim::Gamification.status_for(user2, :followers).score).to eq(1)
    end

    context "when the user is already following the item" do
      let!(:follow) { create(:follow, followable: user2, user: user1) }

      it "does not raise a validation error" do
        expect { described_class.new(form, user1).call }.to broadcast(:ok)
        expect(user2.reload.followers).to include(user1)
        expect(user2.follows_count).to eq(1)
      end
    end
  end
end
