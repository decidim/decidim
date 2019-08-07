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

      context "when the action is delete" do
        before do
          action_log.action = "delete"
        end

        it { is_expected.to be_valid }
      end
    end

    context "when an invalid visibility is given" do
      let(:action_log) { build :action_log, visibility: "foo" }

      it { is_expected.not_to be_valid }
    end

    context "when no visibility is given" do
      let(:action_log) { build :action_log, visibility: nil }

      it { is_expected.not_to be_valid }
    end
  end

  describe "readonly" do
    it "cannot be modified once saved" do
      action_log.save
      action_log.action = :my_new_action

      expect do
        action_log.save
      end.to raise_error(ActiveRecord::ReadOnlyRecord)
    end

    it "cannot be deleted" do
      action_log.save

      expect do
        action_log.destroy
      end.to raise_error(ActiveRecord::ReadOnlyRecord)
    end
  end
end
