# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Vote do
  subject(:vote) { build(:vote) }

  it { is_expected.to be_valid }

  it "is invalid when the voter_id is not present" do
    subject.voter_id = nil
    expect(subject).to be_invalid
  end

  it "is invalid when the election is not present" do
    subject.election = nil
    expect(subject).to be_invalid
  end

  it "is invalid when encrypted_vote_hash is not present" do
    subject.encrypted_vote_hash = nil
    expect(subject).to be_invalid
  end

  it "is invalid with a status that is not included in the allowed status" do
    expect { subject.status("foo") }.to raise_error(ArgumentError)
  end
end
