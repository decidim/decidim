# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    shared_examples_for "CreateCategory command" do
      describe "call" do
        let(:organization) { create(:organization) }
        let(:user) { create(:user, organization:) }
        let(:form_params) do
          {
            "category" => {
              "name_en" => Decidim::Faker::Localized.paragraph(sentence_count: 3),
              "name_es" => Decidim::Faker::Localized.paragraph(sentence_count: 3),
              "name_ca" => Decidim::Faker::Localized.paragraph(sentence_count: 3)
            }
          }
        end
        let(:form) do
          CategoryForm.from_params(
            form_params,
            current_participatory_space: participatory_space
          ).with_context(
            current_organization: organization
          )
        end
        let(:command) { described_class.new(form, participatory_space, user) }

        describe "when the form is not valid" do
          before do
            allow(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't create a category" do
            expect do
              command.call
            end.not_to change(Category, :count)
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new category" do
            expect do
              command.call
            end.to change(participatory_space.categories, :count).by(1)
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with(:create, Decidim::Category, user, {})
              .and_call_original

            expect { command.call }.to change(Decidim::ActionLog, :count)
            action_log = Decidim::ActionLog.last
            expect(action_log.action).to eq("create")
            expect(action_log.version).to be_present
          end
        end
      end
    end
  end
end
