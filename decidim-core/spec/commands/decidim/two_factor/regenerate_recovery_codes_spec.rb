# frozen_string_literal: true

require "spec_helper"

module Decidim
  module TwoFactor
    describe RegenerateRecoveryCodes do
      subject { described_class.new(user) }

      let(:user) { create(:user, :confirmed) }
      let(:codes_count) { Decidim.two_factor_recovery_codes_count }

      context "when everything is ok" do
        it "broadcasts ok with the plain codes and stores only their digests" do
          expect { subject.call }.to broadcast(:ok, all(match(RecoveryCode::FORMAT))).and(change(RecoveryCode, :count).by(codes_count))

          plain_codes = described_class.call(user)[:ok]
          expect(RecoveryCode.where(user:).pluck(:code_digest)).not_to include(*plain_codes)
        end
      end

      context "when the user already has recovery codes" do
        let!(:old_codes) { described_class.call(user)[:ok] }

        it "replaces them with a set of the same size" do
          subject.call

          expect(RecoveryCode.unused.where(user:).count).to eq(codes_count)
          expect(RecoveryCode.redeem!(user, old_codes.first)).to be(false)
        end
      end
    end
  end
end
