# frozen_string_literal: true

require "spec_helper"

module Decidim::System
  describe UpdateOAuthApplication do
    subject { described_class.call(application, form, user) }

    let(:params) do
      {
        name: "Meta Decidim",
        decidim_organization_id: organization.id,
        organization_name: "Ajuntament de Barcelona",
        organization_url: "http://www.barcelona.cat",
        organization_logo: file,
        redirect_uri: "https://meta.decidim.barcelona/users/auth/decidim",
        scopes: %w(profile),
        refresh_tokens_enabled: false
      }
    end
    let(:file) do
      upload_test_file(Decidim::Dev.test_file("city.jpeg", "image/jpeg"))
    end
    let(:application) { create(:oauth_application) }
    let(:organization) { application.organization }
    let(:user) { create(:user, organization:) }
    let(:context) do
      {
        current_user: user,
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

      it "broadcasts :ok and updates the application" do
        expect do
          subject
        end.to broadcast(:ok)

        application.reload

        expect(application.name).to eq("Meta Decidim")
        expect(application.organization_name).to eq("Ajuntament de Barcelona")
        expect(application.organization_url).to eq("http://www.barcelona.cat")
        expect(application.redirect_uri).to eq("https://meta.decidim.barcelona/users/auth/decidim")
        expect(application.scopes.to_s).to eq("profile")
        expect(application.refresh_tokens_enabled?).to be(false)
      end

      it "traces the creation", versioning: true do
        expect(Decidim.traceability)
          .to receive(:update!)
          .with(application, user, a_kind_of(Hash))
          .and_call_original

        expect { subject }.to change(Decidim::ActionLog, :count)

        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
        expect(action_log.version.event).to eq "update"
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

        application.reload

        expect(application.name).not_to eq("Meta Decidim")
      end

      context "when the organizations differ" do
        let(:user) { create(:user) }

        it "broadcasts invalid" do
          expect do
            subject
          end.to broadcast(:invalid)

          application.reload

          expect(application.name).not_to eq("Meta Decidim")
        end
      end
    end
  end
end
