# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies
  describe Abilities::Admin::AdminAbility do
    subject { described_class.new(user, {}) }

    let(:user) { build(:user, :admin) }

    it { is_expected.to be_able_to(:manage, Decidim::Assembly) }
  end
end
