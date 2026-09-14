# frozen_string_literal: true

require "spec_helper"

module Decidim
  module TwoFactor
    describe RecoveryCode do
      let(:user) { create(:user, :confirmed) }
      let!(:codes) { RegenerateRecoveryCodes.call(user)[:ok] }

      describe ".redeem!" do
        it "redeems a valid code once" do
          expect(described_class.redeem!(user, codes.first)).to be(true)
          expect(described_class.unused.where(user:).count).to eq(codes.count - 1)
          expect(described_class.redeem!(user, codes.first)).to be(false)
        end

        it "rejects unknown, malformed and blank codes" do
          expect(described_class.redeem!(user, "zzzz-zzzz")).to be(false)
          expect(described_class.redeem!(user, "not a code")).to be(false)
          expect(described_class.redeem!(user, nil)).to be(false)
        end

        it "ignores codes of another user" do
          other_user = create(:user, :confirmed, organization: user.organization)

          expect(described_class.redeem!(other_user, codes.first)).to be(false)
        end
      end
    end
  end
end
