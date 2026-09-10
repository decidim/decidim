# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Authorization do
    let(:organization) { create(:organization) }
    let(:authorization) { build(:authorization, organization:) }

    shared_examples_for "encrypted authorization metadata decryption" do
      it "encrypts the metadata to the database" do
        expect(
          Decidim::AttributeEncryptor.decrypt(database_metadata["foo"])
        ).to eq(
          ActiveSupport::JSON.encode(expected_foo)
        )
      end

      it "decrypts the final values automatically" do
        final = Decidim::Authorization.find(authorization.id)
        data = final.send(authorization_metadata_key)
        expect(data["foo"]).to eq(expected_foo)
      end
    end

    shared_context "with encrypted authorization metadata" do
      let(:authorization_metadata) { { foo: "bar" } }
      let!(:authorization) do
        data = {}
        data[authorization_metadata_key] = authorization_metadata
        create(:authorization, authorization_status, data)
      end
      let(:database_metadata) do
        JSON.parse(
          ActiveRecord::Base.connection.select_one(
            "SELECT #{authorization_metadata_key} FROM #{described_class.table_name} WHERE id = #{authorization.id}"
          )[authorization_metadata_key.to_s]
        )
      end
      let(:expected_foo) { "bar" }

      it_behaves_like "encrypted authorization metadata decryption"

      context "when storing with update!" do
        let(:expected_foo) { "baz" }
        let(:authorization_metadata) { { foo: "baz" } }

        it_behaves_like "encrypted authorization metadata decryption"
      end

      context "when storing with attribute update" do
        let(:expected_foo) { "biz" }
        let(:authorization_metadata) { { foo: "biz" } }

        before do
          authorization.send("#{authorization_metadata_key}=", authorization_metadata)
          authorization.save!
        end

        it_behaves_like "encrypted authorization metadata decryption"
      end

      context "when storing with attributes=" do
        let(:expected_foo) { "buz" }
        let(:authorization_metadata) { { foo: "buz" } }

        before do
          attributes = {}
          attributes[authorization_metadata_key] = authorization_metadata

          authorization.attributes = attributes
          authorization.save!
        end

        it_behaves_like "encrypted authorization metadata decryption"
      end
    end

    it "is valid" do
      expect(authorization).to be_valid
    end

    context "when leaving verification data around" do
      let(:authorization) do
        build(:authorization, verification_metadata: { sensible_stuff: "123456" })
      end

      it "is not valid" do
        expect(authorization).not_to be_valid
      end
    end

    context "when verification is granted" do
      let!(:authorization) { create(:authorization, name: "dummy_authorization_handler") }

      it "has renewable? method" do
        expect(authorization).to be_renewable
      end

      it "has metadata_cell" do
        expect(authorization.metadata_cell).to be_a String
      end
    end

    context "with metadata" do
      include_context "with encrypted authorization metadata" do
        let(:authorization_metadata_key) { :metadata }
        let(:authorization_status) { :granted }
      end
    end

    context "with verification metadata" do
      include_context "with encrypted authorization metadata" do
        let(:authorization_metadata_key) { :verification_metadata }
        let(:authorization_status) { :pending }
      end
    end

    describe ".create_or_update_from" do
      subject { described_class.create_or_update_from(handler) }

      let(:user) { create(:user) }
      let(:handler_class) do
        Class.new(Decidim::AuthorizationHandler) do
          def authorization_attributes
            super.merge(created_at: Time.zone.local(2022, 1, 31, 16, 21))
          end

          def handler_name
            "foobar"
          end
        end
      end
      let(:handler) { handler_class.from_params(user:) }

      let(:authorization) { Decidim::Authorization.last }

      context "when the handler provides additional arguments for the authorization" do
        it "adds the extra attributes for the created authorization" do
          expect(subject).to be(true)
          expect(authorization.created_at).to eq(Time.zone.local(2022, 1, 31, 16, 21))
        end
      end
    end

    describe "#metadata" do
      let!(:authorization) { create(:authorization, :granted, metadata: authorization_metadata) }
      let(:authorization_metadata) do
        {
          uid: SecureRandom.hex(256),
          foo: "bar",
          baz: "biz",
          dob: "2016-09-16",
          postal_code: "00000",
          municipality: "Babylon"
        }
      end

      it "runs the decryption in a timely manner" do
        start = Time.current
        100.times { Decidim::Authorization.find(authorization.id).metadata }

        # This should actually take ~0.05 seconds during normal performance but
        # the idea of this test is to check that there is no unnecessary delay
        # when running the decryption multiple times.
        #
        # There used to be a performance problem at the
        # `Decidim::AttributeEncryptor` class which caused unnecessary delay
        # when called multiple times.
        expect(Time.current - start).to be < 1
      end
    end

    describe "#record_failed_attempt!" do
      let!(:authorization) { create(:authorization, :pending) }

      it "increments the failed_attempts counter" do
        expect { authorization.record_failed_attempt! }.to change(authorization, :failed_attempts).by(1)
      end

      context "when failed_attempts exceeds the maximum" do
        before do
          authorization.update!(failed_attempts: Decidim.verification_max_failed_attempts)
        end

        it "sets locked_at" do
          authorization.record_failed_attempt!
          expect(authorization.reload.locked_at).to be_present
        end
      end

      context "when failed_attempts does not exceed the maximum" do
        before do
          authorization.update!(failed_attempts: Decidim.verification_max_failed_attempts - 1)
        end

        it "does not set locked_at" do
          authorization.record_failed_attempt!
          expect(authorization.reload.locked_at).to be_nil
        end
      end

      context "with concurrent calls" do
        let!(:authorization) { create(:authorization, :pending, failed_attempts: 0) }

        it "atomically increments and locks when threshold is reached" do
          threads = Decidim.verification_max_failed_attempts.times.map do
            Thread.new do
              auth = Decidim::Authorization.find(authorization.id)
              auth.record_failed_attempt!
            end
          end

          threads.each(&:join)

          reloaded = authorization.reload
          expect(reloaded.failed_attempts).to eq(Decidim.verification_max_failed_attempts)
          expect(reloaded.locked_at).to be_present
        end
      end
    end

    describe "#reset_failed_attempts!" do
      let!(:authorization) { create(:authorization, :pending, failed_attempts: 3, locked_at: Time.current) }

      it "resets failed_attempts to 0" do
        authorization.reset_failed_attempts!
        expect(authorization.failed_attempts).to eq(0)
      end

      it "clears locked_at" do
        authorization.reset_failed_attempts!
        expect(authorization.locked_at).to be_nil
      end
    end

    describe "#locked_for_confirmation?" do
      let!(:authorization) { create(:authorization, :pending) }

      context "when locked_at is nil" do
        it "returns false" do
          expect(authorization.locked_for_confirmation?).to be false
        end
      end

      context "when locked_at is within the unlock window" do
        before do
          authorization.update!(locked_at: Time.current)
        end

        it "returns true" do
          expect(authorization.locked_for_confirmation?).to be true
        end
      end

      context "when locked_at is outside the unlock window" do
        before do
          authorization.update!(locked_at: Decidim.verification_unlock_in.ago - 1.minute)
        end

        it "returns false" do
          expect(authorization.locked_for_confirmation?).to be false
        end
      end
    end

    describe "#clear_expired_lock!" do
      let!(:authorization) { create(:authorization, :pending) }

      context "when locked_at is nil" do
        it "does nothing" do
          authorization.clear_expired_lock!
          expect(authorization.locked_at).to be_nil
        end
      end

      context "when locked_at is within the unlock window" do
        before do
          authorization.update!(locked_at: Time.current, failed_attempts: 5)
        end

        it "does not clear the lock" do
          authorization.clear_expired_lock!
          expect(authorization.reload.locked_at).to be_present
        end
      end

      context "when locked_at is outside the unlock window" do
        before do
          authorization.update!(locked_at: Decidim.verification_unlock_in.ago - 1.minute, failed_attempts: 5)
        end

        it "clears the lock" do
          authorization.clear_expired_lock!
          expect(authorization.reload.locked_at).to be_nil
        end

        it "resets failed_attempts" do
          authorization.clear_expired_lock!
          expect(authorization.reload.failed_attempts).to eq(0)
        end
      end
    end
  end
end
