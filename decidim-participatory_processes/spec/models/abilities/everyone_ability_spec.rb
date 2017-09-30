# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatoryProcesses::Abilities::EveryoneAbility do
  subject { described_class.new(user, {}) }

  let(:user) { build(:user) }

  it "lets the user read processes" do
    expect(subject.permissions[:can][:read]).to include("Decidim::ParticipatoryProcess")
  end
end
