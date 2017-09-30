# frozen_string_literal: true

require "spec_helper"

describe Decidim::Assemblies::Abilities::EveryoneAbility do
  subject { described_class.new(user, {}) }

  let(:user) { build(:user) }

  it "lets the user read assemblies" do
    expect(subject.permissions[:can][:read]).to include("Decidim::Assembly")
  end
end
