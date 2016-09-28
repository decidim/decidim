# frozen_string_literal: true
require "spec_helper"

describe "User", :db do
  let(:user) { build(:user) }

  it "is valid" do
    expect(user).to be_valid
  end

  context "with roles" do
    let(:user) { build(:user, :admin) }

    it "is still valid" do
      expect(user).to be_valid
    end

    context "with an invalid role" do
      let(:user) { build(:user, roles: ["foo"]) }

      it "is not valid" do
        expect(user).to_not be_valid
      end
    end
  end

  describe "validation scopes" do
    context "when a user with the same email exists in another organization" do
      let(:email) { "foo@bar.com" }
      let(:user) { build(:user, email: email) }

      before do
        create(:user, email: email)
      end

      it "is valid" do
        expect(user).to be_valid
      end
    end
  end
end
