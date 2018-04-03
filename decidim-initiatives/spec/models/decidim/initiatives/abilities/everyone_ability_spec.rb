# frozen_string_literal: true

require "spec_helper"
require "cancan/matchers"

describe Decidim::Initiatives::Abilities::EveryoneAbility do
  subject { described_class.new(user, {}) }

  let(:user) { build(:user) }

  context "when lets the user read initiatives" do
    it "created" do
      initiative = build(:initiative, :created)
      expect(subject).not_to be_able_to(:read, initiative)
    end

    it "validating" do
      initiative = build(:initiative, :validating)
      expect(subject).not_to be_able_to(:read, initiative)
    end

    it "discarded" do
      initiative = build(:initiative, :discarded)
      expect(subject).not_to be_able_to(:read, initiative)
    end

    it "published" do
      initiative = build(:initiative)
      expect(subject).to be_able_to(:read, initiative)
    end

    it "rejected" do
      initiative = build(:initiative, :rejected)
      expect(subject).to be_able_to(:read, initiative)
    end

    it "accepted" do
      initiative = build(:initiative, :accepted)
      expect(subject).to be_able_to(:read, initiative)
    end
  end

  it "lets the user search initiative types" do
    expect(subject.permissions[:can][:search]).to include("Decidim::InitiativesType")
  end

  it "lets the user search initiative type scopes" do
    expect(subject.permissions[:can][:search]).to include("Decidim::InitiativesTypeScope")
  end
end
