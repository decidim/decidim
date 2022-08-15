# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UserPresenter, type: :helper do
    let(:presenter) { described_class.new(user) }
    let(:user) { build(:user) }

    describe "#nickname" do
      subject { presenter.nickname }

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

    context "when user is not officialized" do
      describe "#badge" do
        subject { presenter.badge }

        it { is_expected.to eq("") }
      end
    end

    context "when user is officialized" do
      let(:user) { build(:user, :officialized) }

      describe "#badge" do
        subject { presenter.badge }

        it { is_expected.to eq("verified-badge") }
      end
    end

    describe "#profile_path" do
      subject { presenter.profile_path }

      it { is_expected.to eq("/profiles/#{user.nickname}") }
    end

    context "when user is deleted" do
      let(:user) { build(:user, :deleted) }

      describe "#profile_path" do
        subject { presenter.profile_path }

        it { is_expected.to eq("") }
      end
    end

    describe "#display_mention" do
      subject { presenter.display_mention }

      it do
        expect(subject).to \
          have_link(user.nickname, href: "http://#{user.organization.host}/profiles/#{user.nickname}") &
          have_selector(".user-mention")
      end
    end

    context "when user is a group" do
      let(:user) { build(:user_group) }

      describe "#profile_path" do
        subject { presenter.profile_path }

        it { is_expected.to eq("/profiles/#{user.nickname}") }
      end

      describe "#profile_url" do
        subject { presenter.profile_url }

        let(:host) { user.organization.host }

        it { is_expected.to eq("http://#{host}/profiles/#{user.nickname}") }
      end
    end

    describe "#officialization_text" do
      subject { presenter.officialization_text }

      it "returns the default officialization text" do
        expect(subject).to eq("This participant is publicly verified, his/her name or role has been verified to correspond with his/her real name and role")
      end

      context "when the user is officialized as" do
        let(:user) { build(:user, officialized_as: { en: "Foobar", ca: "Fóóbàr" }) }

        it "returns the default officialization text" do
          expect(subject).to eq("Foobar")
        end
      end
    end
  end
end
