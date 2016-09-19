# frozen_string_literal: true
require "spec_helper"

describe "User", :db do
  let(:user) { build(:user) }

  it "is valid" do
    expect(user).to be_valid
  end

  describe "admin?" do
    context "when the user is an admin" do
      before do
        user.roles = ["admin"]
      end

      it { expect(user.admin?).to eq true }
    end

    context "when the user is not an admin" do
      before do
        user.roles = []
      end

      it { expect(user.admin?).to eq false }
    end
  end
end
