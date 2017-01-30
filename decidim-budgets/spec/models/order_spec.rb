# frozen_string_literal: true

require "spec_helper"

describe Decidim::Budgets::Order do
  let(:order) { build :order }
  subject { order }

  describe "validations" do
    it "is valid" do
      expect(subject).to be_valid
    end

    it "is invalid when user is not present" do
      subject.user = nil
      expect(subject).to be_invalid
    end

    it "is invalid when feature is not present" do
      subject.feature = nil
      expect(subject).to be_invalid
    end

    it "is unique for each user and feature" do
      subject.save
      new_order = build :order, user: subject.user, feature: subject.feature
      expect(new_order).to be_invalid
    end
  end
end