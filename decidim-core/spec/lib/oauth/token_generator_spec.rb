# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe OAuth::TokenGenerator do
    describe ".generate" do
      subject { described_class.generate(options) }

      let(:user) { create(:user, :confirmed) }
      let(:organization) { user.organization }
      let(:application) { create(:oauth_application, organization:) }
      let(:scopes) { "profile" }
      let(:options) do
        {
          application: application,
          resource_owner_id: user.id,
          scopes: ::Doorkeeper::OAuth::Scopes.from_string(scopes)
        }
      end

      it "generates a default Doorkeeper token by default" do
        # Default token in Doorkeeper is fetched with:
        # SecureRandom.urlsafe_base64(32)
        #
        # Expected to be a ((4.to_f / 3) * 32).ceil = 43 characters long URL
        # safe base64 encoded string.
        expect(subject).to match(/\A[A-Za-z0-9_=-]{43}\z/)
      end

      %w(user api:read).each do |scope|
        context "with the '#{scope}' scope" do
          let(:scopes) { scope }
          let(:expected_scp) { scope == "user" ? "user" : "anonymous" }

          let(:parts) { subject.split(".") }

          it "generates a valid JWT token" do
            expect(parts.count).to eq(3)

            alg = nil
            payload = nil
            signature = nil
            expect do
              alg = JSON.parse(Base64.urlsafe_decode64(parts[0]))
              payload = JSON.parse(Base64.urlsafe_decode64(parts[1]))
              signature = Base64.urlsafe_decode64(parts[2])
            end.not_to raise_error

            # Expected "configured" (default) signing algorithm
            expect(alg).to eq("alg" => "HS256")

            # Validate the signature
            JWT::JWA.resolve(alg["alg"]).tap do |algo|
              expected_signature = algo.sign(
                data: parts[0..1].join("."),
                signing_key: ::Devise::JWT.config.secret
              )
              expect(signature).to eq(expected_signature)
            end

            # Check the correctness of the payload
            #
            # JWT claims registry:
            # https://www.iana.org/assignments/jwt/jwt.xhtml
            #
            # Note that the `scp` claim is not included in the registry but this
            # is used by Warden::JWTAuth to map the token to the correct Warden
            # / Devise scope (i.e. "user" for regular users). In case this does
            # not match the Warden / Devise scope, the user cannot be
            # authenticated through Warden::JWTAuth (Devise::JWT).
            expect(payload.keys).to match_array(%w(aud sub scp iat exp jti))
            expect(payload).to match(
              a_hash_including(
                "aud" => application.uid,
                "sub" => user.id.to_s,
                "scp" => expected_scp,
                "iat" => an_instance_of(Integer),
                "exp" => an_instance_of(Integer),
                # SecureRandom.uuid as defined by RFC 4122:
                # https://datatracker.ietf.org/doc/html/rfc4122
                "jti" => /\A[0-9a-f]{8}\b-[0-9a-f]{4}\b-[0-9a-f]{4}\b-[0-9a-f]{4}\b-[0-9a-f]{12}\z/
              )
            )
            expect(payload["exp"] - payload["iat"]).to eq(
              Decidim::Api.jwt_expires_in.minutes.to_i
            )
          end
        end
      end
    end
  end
end
