# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UserPresenter, type: :helper do
    let(:user) { build(:user) }

    describe "#nickname" do
      subject { described_class.new(user).nickname }

      it { is_expected.to eq("@#{user.nickname}") }
    end

    context "when user is not officialized" do
      describe "#badge" do
        subject { described_class.new(user).badge }

        it { is_expected.to eq("") }
      end
    end

    context "when user is officialized" do
      let(:user) { build(:user, :officialized) }

      describe "#badge" do
        subject { described_class.new(user).badge }

        it { is_expected.to eq("verified-badge") }
      end
    end

    describe "#profile_path" do
      subject { described_class.new(user).profile_path }

      it { is_expected.to eq("/profiles/#{user.nickname}") }
    end

    context "when user is deleted" do
      let(:user) { build(:user, :deleted) }

      describe "#profile_path" do
        subject { described_class.new(user).profile_path }

        it { is_expected.to eq("") }
      end
    end

    describe "#display_mention" do
      subject { described_class.new(user).display_mention }

      it do
        expect(subject).to \
          have_link(user.nickname, href: "/profiles/#{user.nickname}") &
          have_selector(".user-mention")
      end
    end
  end
end
