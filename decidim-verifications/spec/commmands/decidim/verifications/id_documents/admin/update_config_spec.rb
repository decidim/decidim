# frozen_string_literal: true

require "spec_helper"

module Decidim::Verifications::IdDocuments::Admin
  describe UpdateConfig do
    subject { described_class.new(form) }

    let(:form) do
      ConfigForm.from_params(
        online: online,
        offline: offline,
        offline_explanation: offline_explanation
      ).with_context(current_organization: organization)
    end
    let(:organization) { create :organization }
    let(:online) { true }
    let(:offline) { true }
    let(:offline_explanation) { { en: "Blah" } }

    context "when the form is not authorized" do
      before do
        expect(form).to receive(:valid?).and_return(false)
      end

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      it "updates the organization" do
        subject.call
        organization.reload
        expect(organization.id_documents_methods).to match_array(%w(online offline))
        expect(translated(organization.id_documents_explanation_text)).to eq "Blah"
      end
    end
  end
end
