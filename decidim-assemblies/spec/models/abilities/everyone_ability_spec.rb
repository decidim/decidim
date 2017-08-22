# frozen_string_literal: true

require "spec_helper"

describe Decidim::Assemblies::Abilities::EveryoneAbility do
  let(:user) { build(:user) }

  subject { described_class.new(user, {}) }

  it "lets the user read assemblies" do
    expect(subject.permissions[:can][:read]).to include("Decidim::Assembly")
  end
end
