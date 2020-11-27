# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ShareToken do
    subject { share_token }

    let(:share_token) { build(:share_token, attributes) }
    let(:expired_token) { build(:share_token, :expired, attributes) }
    let(:unbounded_expiration_token) { create(:share_token, attributes.merge(expiration_blank: true)) }

    let(:attributes) do
      {
        token_for: token_for,
        user: user,
        organization: organization,
        expiration_blank: expiration_blank
      }
    end

    let(:user) { create(:user) }
    let(:token_for) { create(:component) }
    let(:organization) { token_for.organization }
    let(:expiration_blank) { nil }

    it { is_expected.to be_valid }

    describe "validations" do
      context "when user is not present" do
        let(:user) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when organization is not present" do
        let(:organization) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when token_for is not present" do
        let(:organization) { create(:organization) }
        let(:token_for) { nil }

        it { is_expected.not_to be_valid }
      end
    end

    describe "defaults" do
      it "generates an alphanumeric 64-character token string" do
        expect(subject.token).to match(/^[a-zA-Z0-9]{64}$/)
      end

      it "sets expires_at attribute to one day from current time after creation" do
        subject.save
        expect(subject.expires_at).to be_within(1.second).of 1.day.from_now
      end

      context "when expiration blank is true" do
        let(:expiration_blank) { true }

        it "sets expires_at as nil after creation" do
          subject.save
          expect(subject.expires_at).to be_nil
        end
      end
    end

    describe "ShareToken.use!" do
      context "when share_token is valid" do
        let(:share_token) { create(:share_token, attributes) }

        it "calls the found share_token's #use! method" do
          expect { ShareToken.use!(token_for: token_for, token: share_token.token) }.to change { subject.reload.times_used }.by(1)
        end
      end

      context "when share_token is not found" do
        it "raises an activerecord error" do
          expect { ShareToken.use!(token_for: token_for, token: "not a valid token") }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    describe "#use!" do
      context "when share_token is valid" do
        it "increments the times_used attribute by one" do
          expect { subject.use! }.to change(subject, :times_used).by(1)
        end

        it "sets last_used_at to current time" do
          subject.use!
          expect(subject.last_used_at).to be_within(1.second).of Time.zone.now
        end
      end

      context "when share_token has expired" do
        let(:share_token) { expired_token }

        it "raises an error" do
          expect { subject.use! }.to raise_error(StandardError)
        end
      end
    end

    describe "#expired?" do
      context "when share_token has not expired" do
        let(:share_token) { create(:share_token, attributes) }

        it "returns true" do
          expect(subject.expired?).to eq false
        end
      end

      context "when share_token expired_at is nil" do
        let(:share_token) { unbounded_expiration_token }

        it "returns nil" do
          expect(subject.expired?).to be_nil
        end
      end

      context "when share_token has expired" do
        let(:share_token) { expired_token }

        it "returns true" do
          expect(subject.expired?).to eq true
        end
      end
    end

    describe "#url" do
      it "returns the shareable url for the token_for object" do
        expect(subject.url).to match(/share_token=#{share_token.token}/)
      end
    end
  end
end
