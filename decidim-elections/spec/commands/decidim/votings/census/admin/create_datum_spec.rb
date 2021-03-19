# frozen_string_literal: true

require "spec_helper"

module Decidim::Votings::Census::Admin
  describe CreateDatum do
    subject { described_class.new(form, dataset, user) }

    let(:dataset) { create(:dataset, organization: user.organization) }
    let(:user) { create(:user, :admin) }
    let(:params) { {
      document_number: document_number,
        document_type: "DNI",
        birthdate: "20010414",
        full_name: "Jane Doe",
        full_address: "Nowhere street 1",
        postal_code: "12345",
        mobile_phone_number: "123456789",
        email: email
     } }

    let(:context) { {
      current_user: user,
      dataset: dataset,
      voting: dataset.voting,
      organization: user.organization} }

    let(:form) { DatumForm.from_params(params).with_context(context) }

    let(:document_number) {"123456789Y"}
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

    it "traces the action", versioning: true do
      expect(Decidim.traceability)
        .to receive(:create)
        .with(
          Decidim::Votings::Census::Datum,
          user,
          kind_of(Hash),
          visibility: "admin-only"
        )
        .and_call_original

      expect { subject.call }.to change(Decidim::ActionLog, :count)
      action_log = Decidim::ActionLog.where(resource_type:"Decidim::Votings::Census::Datum").last
      expect(action_log.version).to be_present
      expect(action_log.version.event).to eq "create"
    end
  end
end
