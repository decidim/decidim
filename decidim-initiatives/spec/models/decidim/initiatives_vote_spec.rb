# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe InitiativesVote do
    let(:vote) { build(:initiative_user_vote) }

    it "is valid" do
      expect(vote).to be_valid
    end
  end
end
