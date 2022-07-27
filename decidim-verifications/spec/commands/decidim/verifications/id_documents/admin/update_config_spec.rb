# frozen_string_literal: true

require "spec_helper"

module Decidim::Verifications::IdDocuments::Admin
  describe UpdateConfig do
    subject { described_class.new(form) }

    let(:form) do
      ConfigForm.from_params(
        online:,
        offline:,
        offline_explanation:
      ).with_context(current_organization: organization, current_user: user)
    end
    let(:organization) { create :organization }
    let(:user) { create :user, organization: }
    let(:online) { true }
    let(:offline) { true }
    let(:offline_explanation) { { en: "Blah" } }

    context "when the form is not authorized" do
      before do
        allow(form).to receive(:valid?).and_return(false)
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

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with(:update_id_documents_config, organization, user)
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
        expect(action_log.version.event).to eq "update"
      end
    end
  end
end
