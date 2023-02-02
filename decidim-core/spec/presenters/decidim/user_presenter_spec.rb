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

        it { is_expected.to eq("") }
      end
    end

    describe "#can_be_contacted?" do
      subject { described_class.new(user).can_be_contacted? }

      context "when user is not blocked" do
        it "can be contacted" do
          expect(subject).to be(true)
        end
      end

      context "when user is blocked" do
        it "cannot be contacted" do
          user.blocked = true

          expect(subject).to be_nil
        end
      end
    end

    describe "#profile_url" do
      subject { described_class.new(user).profile_url }

      it { is_expected.to eq("http://#{user.organization.host}:#{Capybara.server_port}/profiles/#{user.nickname}") }
    end

    describe "#default_avatar_url" do
      subject { described_class.new(user).default_avatar_url }

      it { is_expected.to eq("//#{user.organization.host}:#{Capybara.server_port}#{ActionController::Base.helpers.asset_pack_path("media/images/default-avatar.svg")}") }
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
          have_link(user.nickname, href: "http://#{user.organization.host}:#{Capybara.server_port}/profiles/#{user.nickname}") &
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

        it { is_expected.to eq("http://#{host}:#{Capybara.server_port}/profiles/#{user.nickname}") }
      end

      describe "#can_be_contacted?" do
        subject { described_class.new(user).can_be_contacted? }

        context "when group is not blocked" do
          it "can be contacted" do
            expect(subject).to be(true)
          end
        end

        context "when group is blocked" do
          it "cannot be contacted" do
            user.blocked = true

            expect(subject).to be_nil
          end
        end
      end
    end
  end
end
