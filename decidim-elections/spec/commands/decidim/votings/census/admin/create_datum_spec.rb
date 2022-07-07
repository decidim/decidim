# frozen_string_literal: true

require "spec_helper"

module Decidim::Votings::Census::Admin
  describe CreateDatum do
    subject { described_class.new(form, dataset) }

    let(:dataset) { create(:dataset) }
    let(:datum) { Decidim::Votings::Census::Datum.last }
    let!(:ballot_style) { create(:ballot_style, code: ballot_style_code, voting: dataset.voting) }
    let(:ballot_style_code) { "BS1" }
    let(:user) { create(:user, :admin, organization: dataset.voting.organization) }
    let(:birthdate) { "20010414" }
    let(:params) do
      {
        document_number: document_number,
        document_type: "DNI",
        birthdate: birthdate,
        full_name: "Jane Doe",
        full_address: "Nowhere street 1",
        postal_code: "12345",
        mobile_phone_number: "123456789",
        ballot_style_code: ballot_style_code&.downcase,
        email: email
      }
    end

    let(:context) do
      {
        current_user: user,
        dataset: dataset,
        voting: dataset.voting
      }
    end

    let(:form) { DatumForm.from_params(params).with_context(context) }

    let(:document_number) { "123456789Y" }
    let(:email) { "example@test.org" }

    context "when the form is not valid" do
      let(:document_number) { nil }

      it "broadcasts invalid" do
        expect(subject.call).to broadcast(:invalid)
      end
    end

    context "when the birthdate is not exactly YYYYmmdd" do
      let(:birthdate) { "02/12/2001" }

      it "broadcasts invalid" do
        expect(subject.call).to broadcast(:invalid)
      end
    end

    it "broadcasts ok" do
      expect(subject.call).to broadcast(:ok)
    end

    it "associates to the correct ballot style" do
      subject.call
      expect(datum.ballot_style).to eq(ballot_style)
    end

    context "when the ballot style code is provided" do
      let(:ballot_style_code) { nil }

      it "does not associate any ballot style" do
        subject.call
        expect(datum.ballot_style).to eq(ballot_style)
      end
    end
  end
end
