# frozen_string_literal: true

require "spec_helper"

describe Decidim::Admin::Abilities::UserManagerAbility do
  let(:user) { build(:user, :user_manager) }

  subject { described_class.new(user, {}) }

  context "when the user is not a user manager" do
    let(:user) { build(:user) }

    it "doesn't have any permission" do
      expect(subject.permissions[:can]).to be_empty
      expect(subject.permissions[:cannot]).to be_empty
    end
  end

  it { is_expected.to be_able_to(:manage, :managed_users) }
end
