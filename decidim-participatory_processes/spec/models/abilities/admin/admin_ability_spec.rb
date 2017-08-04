# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatoryProcesses::Abilities::Admin::AdminAbility do
  let(:user) { build(:user, :admin) }

  subject { described_class.new(user, {}) }

  it { is_expected.to be_able_to(:manage, Decidim::ParticipatoryProcess) }
  it { is_expected.to be_able_to(:manage, Decidim::ParticipatoryProcessStep) }
end
