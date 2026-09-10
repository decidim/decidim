# frozen_string_literal: true

require "spec_helper"

describe Decidim::Verifications::ConfirmUserAuthorization do
  subject { described_class.new(authorization, form) }

  let(:authorization) do
    create(
      :authorization,
      :pending,
      name: "cool_method",
      verification_metadata:
    )
  end

  let(:verification_metadata) do
    { secret_code: "XX42YY" }
  end

  let(:form_class) do
    Class.new(Decidim::Form) do
      mimic :authorization

      attribute :secret_code

      validates :secret_code, presence: true

      def verification_metadata
        { "secret_code" => secret_code }
      end
    end
  end

  let(:form) { form_class.new(secret_code:) }

  let(:authorizations) do
    Decidim::Verifications::Authorizations.new(organization: user.organization, user:, granted: true)
  end

  let(:user) { authorization.user }

  context "when the form is not valid" do
    let(:secret_code) { nil }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end

    it "records the failed attempt on the authorization" do
      subject.call
      expect(authorization.reload.failed_attempts).to eq(1)
    end
  end

  context "when the authorization is already confirmed" do
    let(:secret_code) { "XX42YY" }

    before { authorization.grant! }

    it "broadcasts already confirmed" do
      expect { subject.call }.to broadcast(:already_confirmed)
    end

    it "resets the failed attempts on the authorization" do
      authorization.update!(failed_attempts: 3)
      subject.call
      expect(authorization.reload.failed_attempts).to eq(0)
    end
  end

  context "when the authorization is locked" do
    let(:secret_code) { "XX42YY" }

    before do
      authorization.update!(locked_at: Time.current, failed_attempts: Decidim.verification_max_failed_attempts + 1)
    end

    it "broadcasts locked" do
      expect { subject.call }.to broadcast(:locked)
    end

    context "when the lock has expired" do
      before do
        authorization.update!(locked_at: Decidim.verification_unlock_in.ago - 1.minute)
      end

      it "clears the expired lock and proceeds" do
        expect { subject.call }.to broadcast(:ok)
      end
    end
  end

  context "when the verification code has expired" do
    let(:secret_code) { "XX42YY" }

    before do
      authorization.update!(verification_metadata: { secret_code: "XX42YY", code_sent_at: Decidim.verification_code_expiry_minutes.minutes.ago - 1.minute })
    end

    it "broadcasts expired" do
      expect { subject.call }.to broadcast(:expired)
    end

    it "clears the verification metadata" do
      subject.call
      expect(authorization.reload.verification_metadata).to eq({})
    end

    it "resets the failed attempts" do
      authorization.update!(failed_attempts: 3)
      subject.call
      expect(authorization.reload.failed_attempts).to eq(0)
    end
  end

  context "when the verification code has not expired" do
    let(:secret_code) { "XX42YY" }

    before do
      authorization.update!(verification_metadata: { secret_code: "XX42YY", code_sent_at: Decidim.verification_code_expiry_minutes.minutes.ago + 1.minute })
    end

    it "broadcasts ok" do
      expect { subject.call }.to broadcast(:ok)
    end
  end

  context "when there is no code_sent_at timestamp" do
    let(:secret_code) { "XX42YY" }

    it "does not expire the code" do
      expect { subject.call }.to broadcast(:ok)
    end
  end

  context "when there is only a letter_sent_at timestamp" do
    let(:secret_code) { "XX42YY" }

    before do
      authorization.update!(verification_metadata: { secret_code: "XX42YY", letter_sent_at: Decidim.verification_code_expiry_minutes.minutes.ago - 1.hour })
    end

    it "does not expire the code" do
      expect { subject.call }.to broadcast(:ok)
    end
  end

  context "when the authorization fails too many times" do
    let(:secret_code) { "wrong" }

    it "locks the authorization after exceeding max attempts" do
      (Decidim.verification_max_failed_attempts + 1).times { subject.call }
      expect(authorization.reload.locked_at).to be_present
    end
  end

  context "when everything is ok" do
    let(:secret_code) { "XX42YY" }

    it "broadcasts ok" do
      expect { subject.call }.to broadcast(:ok)
    end

    it "confirms the authorization for the user" do
      expect { subject.call }.to change(authorizations, :count).by(1)
    end

    it "resets the failed attempts on the authorization" do
      authorization.update!(failed_attempts: 3)
      subject.call
      expect(authorization.reload.failed_attempts).to eq(0)
    end

    context "when there is a problem with the SMS service" do
      before do
        expect(authorization).to receive(:grant!).and_raise(StandardError, "Something went wrong")
      end

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end
  end
end
