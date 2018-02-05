# frozen_string_literal: true

require "spec_helper"

describe Decidim::ActionLog do
  subject { action_log }

  let(:action_log) { build :action_log }

  it { is_expected.to be_valid }

  describe "validations" do
    context "when no user is given" do
      let(:action_log) { build :action_log, user: nil, organization: build(:organization) }

      it { is_expected.not_to be_valid }
    end

    context "when no action is given" do
      let(:action_log) { build :action_log, action: nil }

      it { is_expected.not_to be_valid }
    end

    context "when no organization is given" do
      let(:action_log) { build :action_log, organization: nil, participatory_space: build(:participatory_process) }

      it { is_expected.not_to be_valid }
    end

    context "when no resource is given" do
      let(:action_log) { build :action_log, resource: nil }

      it { is_expected.not_to be_valid }
    end
  end
end
