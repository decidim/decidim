# frozen_string_literal: true

require "spec_helper"
require "cancan/matchers"

describe Decidim::Initiatives::Abilities::NonLoggedUserAbility do
  subject { described_class.new(nil, {}) }

  context "when lets the user request membership" do
    it "published initiatives" do
      initiative = build(:initiative)
      expect(subject).not_to be_able_to(:request_membership, initiative)
    end

    it "non published initiatives" do
      initiative = build(:initiative, :created)
      expect(subject).to be_able_to(:request_membership, initiative)
    end
  end

  it "lets the user support initiatives" do
    expect(subject).to be_able_to(:vote, Decidim::Initiative)
  end
end
