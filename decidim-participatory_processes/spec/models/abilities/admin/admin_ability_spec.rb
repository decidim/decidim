# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe Abilities::Admin::AdminAbility do
    subject { described_class.new(user, {}) }

    let(:user) { build(:user, :admin) }

    it { is_expected.to be_able_to(:manage, Decidim::ParticipatoryProcess) }
    it { is_expected.to be_able_to(:manage, Decidim::ParticipatoryProcessStep) }
    it { is_expected.to be_able_to(:manage, Decidim::ParticipatoryProcessPrivateUser) }
  end
end
