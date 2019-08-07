# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Sortitions
    module Admin
      describe CreateSortition do
        let(:organization) { create(:organization) }
        let(:author) { create(:user, :admin, organization: organization) }
        let(:participatory_process) { create(:participatory_process, organization: organization) }
        let(:proposal_component) { create(:proposal_component, participatory_space: participatory_process) }
        let(:dice) { ::Faker::Number.between(1, 6) }
        let(:target_items) { ::Faker::Number.number(2) }
        let(:witnesses) { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
        let(:additional_info) { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
        let(:title) { Decidim::Faker::Localized.sentence(3) }
        let(:category) { create(:category, participatory_space: participatory_process) }
        let(:params) do
          {
            decidim_proposals_component_id: proposal_component.id,
            decidim_category_id: category.id,
            dice: dice,
            title: title,
            target_items: target_items,
            witnesses: witnesses,
            additional_info: additional_info
          }
        end

        let(:sortition_component) { create(:sortition_component, participatory_space: participatory_process) }

        let(:context) do
          {
            current_component: sortition_component,
            current_user: author
          }
        end

        let(:form) { SortitionForm.from_params(sortition: params).with_context(context) }
        let(:command) { described_class.new(form) }

        describe "when the form is not valid" do
          before do
            expect(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't create the sortition" do
            expect do
              command.call
            end.to change { Sortition.where(component: sortition_component).count }.by(0)
          end
        end

        describe "when the form is valid" do
          let!(:proposals) do
            create_list(:proposal, target_items.to_i,
                        component: proposal_component,
                        created_at: Time.now.utc - 1.day)
          end

          before do
            expect(form).to receive(:invalid?).and_return(false)
          end

          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "Creates a sortition" do
            expect do
              command.call
            end.to change { Sortition.where(component: sortition_component).count }.by(1)
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:create!)
              .with(Sortition, author, kind_of(Hash))
              .and_call_original

            expect { command.call }.to change(Decidim::ActionLog, :count)
            action_log = Decidim::ActionLog.last
            expect(action_log.version).to be_present
          end

          it "The created sortition contains a list of selected proposals" do
            command.call
            sortition = Sortition.where(component: sortition_component).last
            expect(sortition.selected_proposals).not_to be_empty
          end

          it "The created sortition contains a list of candidate proposals" do
            command.call
            sortition = Sortition.where(component: sortition_component).last
            expect(sortition.candidate_proposals).not_to be_empty
          end

          it "Has a category" do
            command.call
            sortition = Sortition.where(component: sortition_component).last
            expect(sortition.category).to eq(category)
          end

          it "Has a reference" do
            command.call
            sortition = Sortition.where(component: sortition_component).last
            expect(sortition.reference).not_to be_blank
          end

          it "sends a notification to the participatory space followers" do
            follower = create(:user, organization: organization)
            create(:follow, followable: participatory_process, user: follower)

            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: "decidim.events.sortitions.sortition_created",
                event_class: Decidim::Sortitions::CreateSortitionEvent,
                resource: kind_of(Sortition),
                followers: [follower]
              )

            command.call
          end
        end
      end
    end
  end
end
