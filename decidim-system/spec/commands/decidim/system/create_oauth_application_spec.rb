# frozen_string_literal: true

require "spec_helper"

module Decidim::System
  describe CreateOAuthApplication do
    subject { described_class.call(form) }

    let(:organization) { create(:organization) }
    let(:params) do
      {
        name: "Meta Decidim",
        decidim_organization_id: organization.id,
        organization_name: "Ajuntament de Barcelona",
        organization_url: "http://www.barcelona.cat",
        organization_logo: file,
        redirect_uri: "https://meta.decidim.barcelona/users/auth/decidim"
      }
    end
    let(:file) do
      Rack::Test::UploadedFile.new(
        Decidim::Dev.test_file("city.jpeg", "image/jpeg"),
        "image/jpeg"
      )
    end
    let(:context) do
      {
        current_user: create(:user, organization:),
        current_organization: organization
      }
    end
    let(:form) do
      OAuthApplicationForm.from_params(params).with_context(context)
    end

    describe "when valid" do
      before do
        allow(form).to receive(:valid?).and_return(true)
      end

      it "broadcasts :ok and creates the application" do
        expect do
          subject
        end.to broadcast(:ok)

        expect(organization.oauth_applications.count).to eq(1)
      end

      it "sets the scopes as profile" do
        subject

        expect(organization.oauth_applications.last.scopes.to_s).to eq("profile")
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:create!)
          .with(Decidim::OAuthApplication, context[:current_user], a_kind_of(Hash))
          .and_call_original

        expect { subject }.to change(Decidim::ActionLog, :count)

        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
        expect(action_log.version.event).to eq "create"
      end
    end

    describe "when invalid" do
      before do
        allow(form).to receive(:valid?).and_return(false)
      end

      it "broadcasts invalid" do
        expect do
          subject
        end.to broadcast(:invalid)

        expect(organization.oauth_applications.count).to eq(0)
      end
    end
  end
end
