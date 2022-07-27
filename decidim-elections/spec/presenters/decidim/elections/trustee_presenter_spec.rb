# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    describe TrusteePresenter, type: :helper do
      subject(:presenter) { described_class.new(trustee) }

      let(:trustee) { create :trustee, public_key: }
      let(:public_key) do
        {
          kty: "RSA",
          n: "0vx7agoebGcQSuuPiLJXZptN9nndrQmbXEps2aiAFbWhM78LhWx4cbbfAAt" \
             "VT86zwu1RK7aPFFxuhDR1L6tSoc_BJECPebWKRXjBZCiFV4n3oknjhMstn6" \
             "4tZ_2W-5JsGY4Hc5n9yBXArwl93lqt7_RN5w6Cf0h4QyQ5v-65YGjQR0_FD" \
             "W2QvzqY368QQMicAtaSqzs8KJZgnYb9c7d0zgdAZHzu6qMQvRL5hajrn1n9" \
             "1CbOpbISD08qNLyrdkt-bFTWhAI4vMQFh6WeZu0fM4lFd2NcRwr3XPksINH" \
             "aQ-G_xBniIqbw0Ls1jF44-csFCur-kEgU8awapJzKnqDKgw",
          e: "AQAB",
          alg: "RS256",
          kid: "2011-04-29"
        }.to_json
      end

      describe "#public_key_thumbprint" do
        subject { presenter.public_key_thumbprint }

        it "returns the thumbprint for the JWK public key according the RFC 7638 specification" do
          expect(subject).to eq "<pre class='text-small text-muted'>NzbLsXh8uDCcd-6\nMNwXF4W_7noWX\nFZAfHkxZsRGC9Xs</pre>"
        end

        context "when the public key is not present" do
          let(:public_key) { nil }

          it { expect(subject).to be_nil }
        end

        context "when the public key is empty" do
          let(:public_key) { "" }

          it { expect(subject).to be_nil }
        end
      end
    end
  end
end
