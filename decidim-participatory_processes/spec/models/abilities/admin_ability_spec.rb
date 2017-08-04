# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatoryProcesses::Abilities::AdminAbility do
  let(:user) { build(:user, :admin) }
  let(:context) { {} }

  subject { described_class.new(user, context) }

  it { is_expected.to be_able_to(:read, Decidim::ParticipatoryProcess) }
end
