# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UpdateOrganization do
    describe "call" do
      let(:organization) { create(:organization) }
      let(:user) { create(:user, organization:) }
      let(:params) do
        {
          organization: {
            name: { en: "My super organization" },
            reference_prefix: "MSO",
            time_zone: "Hawaii",
            default_locale: "en",
            badges_enabled: true,
            send_welcome_notification: false,
            admin_terms_of_service_body: { en: Faker::Lorem.paragraph },
            rich_text_editor_in_public_views: true,
            machine_translation_display_priority: "translation",
            enable_machine_translations: true
          }
        }
      end
      let(:context) do
        {
          current_user: user,
          current_organization: organization
        }
      end
      let(:form) do
        OrganizationForm.from_params(params).with_context(context)
      end
      let(:command) { described_class.new(form, organization) }

      describe "when the form is not valid" do
        before do
          allow(form).to receive(:invalid?).and_return(true)
        end

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end

        it "does not update the organization" do
          command.call
          organization.reload

          expect(translated(organization.name)).not_to eq("My super organization")
        end
      end

      describe "when the form is valid" do
        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "traces the update", versioning: true do
          expect(Decidim.traceability)
            .to receive(:update!)
            .with(organization, user, a_kind_of(Hash))
            .and_call_original

          expect { command.call }.to change(Decidim::ActionLog, :count)

          action_log = Decidim::ActionLog.last
          expect(action_log.version).to be_present
          expect(action_log.version.event).to eq "update"
        end

        it "updates the organization in the organization" do
          expect { command.call }.to broadcast(:ok)
          organization.reload

          expect(translated(organization.name)).to eq("My super organization")
          expect(organization.rich_text_editor_in_public_views).to be(true)
          expect(organization.enable_machine_translations).to be(true)
        end
      end
    end
  end
end
