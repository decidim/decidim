# frozen_string_literal: true

require "spec_helper"
require "decidim/templates/test/shared_examples/copies_all_questionnaire_contents_examples"

module Decidim
  module Templates
    module Admin
      describe CopyTemplate do
        let(:organization) { create(:organization) }
        let(:template) { create(:template, organization:) }
        let(:user) { create(:user, organization:) }

        describe "when the template is invalid" do
          before do
            template.update(name: nil)
          end

          it "broadcasts invalid" do
            expect { described_class.call(template, user) }.to broadcast(:invalid)
          end
        end

        describe "when the template is valid" do
          let(:destination_questionnaire) do
            events = described_class.call(template, user)
            expect(events).to have_key(:ok)
            events[:ok].templatable
          end

          it "applies template attributes to the questionnaire" do
            expect(destination_questionnaire.title).to eq(template.templatable.title)
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

          context "when the questionnaire has all question types and display conditions" do
            let!(:template) { create(:questionnaire_template, :with_all_questions) }

            it_behaves_like "copies all questionnaire contents"
          end
        end
      end
    end
  end
end
