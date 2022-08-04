# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UserPresenter, type: :helper do
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

        it { is_expected.to eq("@blocked_user") }
      end
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
          have_link(user.nickname, href: "http://#{user.organization.host}/profiles/#{user.nickname}") &
          have_selector(".user-mention")
      end
    end

    context "when user is a group" do
      let(:user) { build(:user_group) }

      describe "#profile_path" do
        subject { described_class.new(user).profile_path }

        it { is_expected.to eq("/profiles/#{user.nickname}") }
      end

      describe "#profile_url" do
        subject { described_class.new(user).profile_url }

        let(:host) { user.organization.host }

        it { is_expected.to eq("http://#{host}/profiles/#{user.nickname}") }
      end
    end
  end
end
