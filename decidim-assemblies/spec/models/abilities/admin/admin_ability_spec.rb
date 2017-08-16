# frozen_string_literal: true

require "spec_helper"

describe Decidim::Assemblies::Abilities::Admin::AdminAbility do
  let(:user) { build(:user, :admin) }

  subject { described_class.new(user, {}) }

  it { is_expected.to be_able_to(:manage, Decidim::Assembly) }
end
