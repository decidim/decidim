# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Templates
    module Admin
      describe CopyProposalAnswerTemplate do
        let(:template) { create(:template, :proposal_answer) }

        let(:user) { create(:user, :admin, organization: template.organization) }

        describe "when the template is invalid" do
          before do
            template.update(name: nil)
          end

          it "broadcasts invalid" do
            expect { described_class.call(template, user) }.to broadcast(:invalid)
          end
        end

        describe "when the template is valid" do
          let(:destination_template) do
            events = described_class.call(template, user)
            expect(events).to have_key(:ok)
            events[:ok]
          end

          it "applies template attributes to the questionnaire" do
            expect(destination_template.name).to eq(template.name)
            expect(destination_template.description).to eq(template.description)
            expect(destination_template.field_values).to eq(template.field_values)
            expect(destination_template.templatable).to eq(template.templatable)
            expect(destination_template.target).to eq(template.target)
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with("duplicate", Decidim::Templates::Template, user)
              .and_call_original

            expect { described_class.call(template, user) }.to change(Decidim::ActionLog, :count)
            action_log = Decidim::ActionLog.last
            expect(action_log.version).to be_present
          end
        end
      end
    end
  end
end
