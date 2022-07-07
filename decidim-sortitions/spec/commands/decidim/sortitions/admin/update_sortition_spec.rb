# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Sortitions
    module Admin
      describe UpdateSortition do
        let(:additional_info) { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(word_count: 4) }.except("machine_translations") }
        let(:title) { Decidim::Faker::Localized.sentence(word_count: 3).except(:machine_translations) }
        let(:sortition) { create(:sortition) }
        let(:user) { create :user, :admin, :confirmed }
        let(:params) do
          {
            id: sortition.id,
            sortition: {
              title: title,
              additional_info: additional_info
            }
          }
        end

        let(:context) do
          {
            current_user: user,
            current_component: sortition.component
          }
        end

        let(:form) { EditSortitionForm.from_params(params).with_context(context) }
        let(:command) { described_class.new(form) }

        describe "when the form is not valid" do
          before do
            allow(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end
        end

        describe "when the form is valid" do
          before do
            allow(form).to receive(:invalid?).and_return(false)
          end

          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "Updates the title" do
            command.call
            sortition.reload
            expect(sortition.title.except("machine_translations")).to eq(title)
          end

          it "Updates the additional info" do
            command.call
            sortition.reload
            expect(sortition.additional_info.except("machine_translations")).to eq(additional_info)
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:update!)
              .with(sortition, user, kind_of(Hash))
              .and_call_original

            expect { command.call }.to change(Decidim::ActionLog, :count)
            action_log = Decidim::ActionLog.last
            expect(action_log.version).to be_present
          end
        end
      end
    end
  end
end
