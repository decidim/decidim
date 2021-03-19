# frozen_string_literal: true

require "spec_helper"

module Decidim::Votings::Census::Admin
  describe CreateDatum do
    subject { described_class.new(form, dataset, user) }

    let(:dataset) { create(:dataset, organization: user.organization) }
    let(:user) { create(:user, :admin) }
    let(:params) do
      {
        document_number: document_number,
        document_type: "DNI",
        birthdate: "20010414",
        full_name: "Jane Doe",
        full_address: "Nowhere street 1",
        postal_code: "12345",
        mobile_phone_number: "123456789",
        email: email
      }
    end

    let(:context) do
      {
        current_user: user,
        dataset: dataset,
        voting: dataset.voting,
        organization: user.organization
      }
    end

    let(:form) { DatumForm.from_params(params).with_context(context) }

    let(:document_number) { "123456789Y" }
    let(:email) {"example@test.org"}

    context "when the form is not valid" do
      let(:document_number) {}

      it "broadcasts invalid" do
        expect(subject.call).to broadcast(:invalid)
      end
    end

    it "broadcasts ok" do
      expect(subject.call).to broadcast(:ok)
    end
  end
end
