# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UpdateOrganizationAppearance do
    describe "call" do
      let(:organization) { create(:organization, show_statistics: true) }
      let(:user) { create(:user, organization: organization) }
      let(:params) do
        {
          organization: {
            description_en: "My description",
            description_es: "Mi descripción",
            description_ca: "La meva descripció",
            show_statistics: false,
            header_snippets: '<script>alert("Hello");</script>',
            favicon: File.new(Decidim::Dev.asset("icon.png"))
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
        OrganizationAppearanceForm.from_params(params).with_context(context)
      end
      let(:command) { described_class.new(organization, form) }

      describe "when the form is not valid" do
        before do
          expect(form).to receive(:invalid?).and_return(true)
        end

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end

        it "doesn't update the organization" do
          command.call
          organization.reload

          expect(organization.show_statistics).to be_truthy
        end
      end

      describe "when the organization is not valid" do
        before do
          expect(form).to receive(:invalid?).and_return(false)
          expect(organization).to receive(:valid?).at_least(:once).and_return(false)
          organization.errors.add(:official_img_header, "Image too big")
          organization.errors.add(:official_img_footer, "Image too big")
        end

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end

        it "adds errors to the form" do
          command.call

          expect(form.errors[:official_img_header]).not_to be_empty
          expect(form.errors[:official_img_footer]).not_to be_empty
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

          expect(organization.show_statistics).to be_falsey
        end

        it "does not save header snippets" do
          expect { command.call }.to broadcast(:ok)
          organization.reload

          expect(organization.header_snippets).not_to be_present
        end

        describe "when header snippets are configured" do
          before do
            allow(Decidim).to receive(:enable_html_header_snippets).and_return(true)
          end

          it "saves header snippets" do
            expect { command.call }.to broadcast(:ok)
            organization.reload

            expect(organization.header_snippets).to be_present
          end
        end

        context "when there's a favicon in the params" do
          it "does set a favicon for the organization" do
            command.call
            organization.reload

            expect(organization.favicon.small).to be_present
          end
        end
      end
    end
  end
end
