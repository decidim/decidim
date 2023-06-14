# frozen_string_literal: true

require "spec_helper"

describe Decidim::PersonalUserPresenter, type: :helper do
  let(:user) { build(:user) }

  describe "#nickname" do
    subject { described_class.new(user).nickname }

    context "when not blocked" do
      it { is_expected.to eq("@#{user.nickname}") }
    end

    context "when blocked" do
      before do
        user.blocked = true
      end

      it { is_expected.to eq("") }
    end
  end

  describe "#name" do
    subject { described_class.new(user).name }

    context "when not blocked" do
      it { is_expected.to eq(user.name) }
    end

    context "when blocked" do
      before do
        user.blocked = true
      end

      it { is_expected.to eq("") }
    end
  end
end
