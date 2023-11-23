# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe UpdateProposalState do
        let(:form_klass) { Decidim::Proposals::Admin::ProposalStateForm }

        let(:component) { create(:proposal_component) }
        let(:organization) { component.organization }
        let(:user) { create(:user, :admin, :confirmed, organization:) }
        let(:state_params) do
          {
            title: { "en" => "Editable state" },
            description: { "en" => "Editable description" },
            announcement_title: { "en" => "Editable announcement title" },
            token: "editable",
            css_class: "csseditable",
            default: false,
            answerable: false,
            notifiable: false,
            gamified: false,
            system: true
          }
        end
        let!(:state) { create(:proposal_state, component:, **state_params) }

        let(:form) do
          form_klass.from_params(
            form_params
          ).with_context(
            current_organization: organization,
            current_participatory_space: component.participatory_space,
            current_user: user,
            current_component: component
          )
        end
        let(:form_params) do
          {
            title: { en: "A reasonable proposal title" },
            description: { en: "A reasonable proposal body" },
            announcement_title: { en: "A reasonable proposal announcement title" },
            token: "custom",
            css_class: "fooo",
            default: true,
            answerable: true,
            notifiable: true,
            system: false,
            gamified: true
          }
        end

        describe "call" do
          let(:command) do
            described_class.new(form, state)
          end

          describe "when the form is not valid" do
            before do
              allow(form).to receive(:invalid?).and_return(true)
            end

            it "broadcasts invalid" do
              expect { command.call }.to broadcast(:invalid)
            end

            it "does not update title of the proposal state" do
              expect { command.call }.not_to change(state, :title)
            end

            it "does not update the proposal state" do
              expect { command.call }.not_to change(state, :token)
            end
          end

          describe "when the form is valid" do
            it "broadcasts ok" do
              expect { command.call }.to broadcast(:ok)
            end

            it "updates the proposal state" do
              expect do
                command.call
              end.to change(state, :title)
            end

            it "traces the update", versioning: true do
              expect(Decidim.traceability)
                .to receive(:update!)
                .with(state, user, a_kind_of(Hash))
                .and_call_original

              expect { command.call }.to change(Decidim::ActionLog, :count)

              action_log = Decidim::ActionLog.last
              expect(action_log.version).to be_present
              expect(action_log.version.event).to eq "update"
            end

            [:title, :announcement_title, :description, :css_class, :default, :answerable, :notifiable, :gamified].each do |field|
              it "updates the #{field}" do
                expect { command.call }.to change(state, field)
              end
            end

            [:token, :system].each do |field|
              it "does not updates the #{field}" do
                expect { command.call }.not_to change(state, field)
              end
            end
          end
        end
      end
    end
  end
end
