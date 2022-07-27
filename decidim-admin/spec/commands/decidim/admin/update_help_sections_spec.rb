# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UpdateHelpSections do
    let(:organization) { create(:organization, external_domain_whitelist: []) }
    let(:user) { create(:user, organization:) }
    let(:form) { Decidim::Admin::HelpSectionsForm.from_params(attributes) }
    let(:command) { described_class.new(form, organization, user) }
    let(:attributes) do
      {
        sections: {
          1 => { "id" => "assembly", "content" => { en: "Repelle" } }
        }
      }
    end

    describe "when the form is valid" do
      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "update help sections" do
        command.call
        expect(Decidim::ContextualHelpSection.find_by("section_id" => "assembly").content).to eq({ "en" => "Repelle" })
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with("update", Decidim::ContextualHelpSection, user, { "resource" => { "title" => "Assembly" } })
          .and_call_original

        expect { command.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.action).to eq("update")
        expect(action_log.version).to be_present
      end
    end

    describe "when the form is not valid" do
      before do
        allow(form).to receive(:valid?).and_return(false)
      end

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end

      it "doesn't update help sections" do
        expect(Decidim::ContextualHelpSection.find_by("id" => "assembly")).to be_nil
      end
    end
  end
end
