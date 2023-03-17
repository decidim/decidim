# frozen_string_literal: true

require "spec_helper"

describe Decidim::Verifications::ConfirmUserAuthorization do
  subject { described_class.new(authorization, form, session) }

  let(:session) { {} }

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

    it "remembers the failed attempt in the session" do
      subject.call
      expect(session[:failed_attempts]).to eq(1)
    end
  end

  context "when the authorization is already confirmed" do
    let(:secret_code) { "XX42YY" }

    before { authorization.grant! }

    it "broadcasts already confirmed" do
      expect { subject.call }.to broadcast(:already_confirmed)
    end

    it "resets the failed attempts in the session" do
      subject.call
      expect(session[:failed_attempts]).to eq(0)
    end
  end

  context "when the authorization fails too many times in a row" do
    let(:secret_code) { "XX42YY" }
    let(:session) { { failed_attempts: 3 } }

    it "throttles before proceeding" do
      expect(subject).to receive(:throttle!) # rubocop:disable RSpec/SubjectStub
      expect { subject.call }.to broadcast(:ok)
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

    it "resets the failed attempts in the session" do
      subject.call
      expect(session[:failed_attempts]).to eq(0)
    end

    context "when there's a problem with the SMS service" do
      before do
        expect(authorization).to receive(:grant!).and_raise(StandardError, "Somewthing went wrong")
      end

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end
  end
end
