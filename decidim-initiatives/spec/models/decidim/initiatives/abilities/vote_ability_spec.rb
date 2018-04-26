# frozen_string_literal: true

require "spec_helper"
require "cancan/matchers"

describe Decidim::Initiatives::Abilities::VoteAbility do
  subject { described_class.new(user, {}) }

  context "when Authorization required" do
    before do
      Decidim::Initiatives.do_not_require_authorization = false
    end

    context "and users non verified" do
      let(:user) { build(:user) }
      let(:initiative) { build(:initiative, organization: user.organization) }

      it "cannot vote" do
        expect(subject).not_to be_able_to(:vote, initiative)
      end

      it "cannot unvote" do
        expect(subject).not_to be_able_to(:unvote, initiative)
      end
    end
  end

  context "when authorization not required" do
    before do
      Decidim::Initiatives.do_not_require_authorization = true
    end

    after do
      Decidim::Initiatives.do_not_require_authorization = false
    end

    context "and users non verified" do
      let(:user) { build(:user) }
      let(:initiative) { build(:initiative, organization: user.organization) }

      it "can vote" do
        expect(subject).to be_able_to(:vote, initiative)
        expect(subject).not_to be_able_to(:unvote, initiative)
      end

      it "can unvote" do
        create(:initiative_user_vote, initiative: initiative, author: user)

        expect(subject).not_to be_able_to(:vote, initiative)
        expect(subject).to be_able_to(:unvote, initiative)
      end
    end
  end

  context "when users from a different organization" do
    let(:user) { create(:authorization).user }
    let(:initiative) { build(:initiative) }

    it "cannot vote" do
      expect(subject).not_to be_able_to(:vote, initiative)
    end

    it "cannot unvote" do
      expect(subject).not_to be_able_to(:unvote, initiative)
    end
  end

  context "when users verified within the same organziation" do
    let(:organization) { create(:organization) }
    let(:user) { create(:authorization, user: create(:user, organization: organization)).user }
    let(:initiative) { create(:initiative, organization: organization) }

    it "can vote" do
      expect(subject).to be_able_to(:vote, initiative)
      expect(subject).not_to be_able_to(:unvote, initiative)
    end

    it "can unvote" do
      create(:initiative_user_vote, initiative: initiative, author: user)

      expect(subject).not_to be_able_to(:vote, initiative)
      expect(subject).to be_able_to(:unvote, initiative)
    end
  end
end
