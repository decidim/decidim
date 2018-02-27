# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies
  describe Abilities::AdminAbility do
    subject { described_class.new(user, context) }

    let(:user) { build(:user, :admin) }
    let(:context) { {} }

    it { is_expected.to be_able_to(:read, Decidim::Assembly) }
    it { is_expected.to be_able_to(:read, Decidim::AssemblyParticipatoryProcess) }
  end
end
