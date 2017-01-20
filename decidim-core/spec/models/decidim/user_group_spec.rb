# frozen_string_literal: true
require "spec_helper"

module Decidim
  describe UserGroup, :db do
    subject { create(:user_group) }

    it "is valid" do
      expect(subject).to be_valid
    end

    it "has an association of users" do
      subject.users << create(:user)
      subject.users << create(:user)
      expect(subject.users.count).to eq(2)
    end

    describe "#verify!" do
      it "mark the user group as verified" do
        subject.verify!
        expect(subject).to be_verified
      end
    end
  end
end
