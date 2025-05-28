# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    module Admin
      describe UpdateQuestions do
        let(:organization) { create(:organization, available_locales: [:en]) }
        let(:current_user) { create(:user, :admin, :confirmed, organization:) }
        let(:participatory_process) { create(:participatory_process, organization:) }
        let(:component) { create(:elections_component, participatory_space: participatory_process) }
        let(:election) { create(:election, component:) }

        let!(:first_question) do
          create(:election_question, election:, body: { en: "First Q" }, description: { en: "Desc 1" }, position: 0)
        end
        let!(:second_question) do
          create(:election_question, election:, body: { en: "Second Q" }, description: { en: "Desc 2" }, position: 1)
        end

        let(:first_question_first_option) { first_question.response_options[0] }
        let(:first_question_second_option) { first_question.response_options[1] }
        let(:second_question_first_option) { second_question.response_options[0] }
        let(:second_question_second_option) { second_question.response_options[1] }

        let(:context_params) do
          { current_organization: organization, current_user: current_user }
        end

        context "when updating an existing question" do
          let(:update_params) do
            {
              "questions" => [
                {
                  "id" => first_question.id,
                  "body" => { en: "First Q updated" },
                  "description" => { en: "Desc updated" },
                  "position" => first_question.position,
                  "question_type" => first_question.question_type,
                  "response_options" => [
                    { "id" => first_question_first_option.id, "body" => { en: "Updated Option" } },
                    { "id" => first_question_second_option.id, "body" => first_question_second_option.body }
                  ]
                },
                {
                  "id" => second_question.id,
                  "body" => second_question.body,
                  "description" => second_question.description,
                  "position" => second_question.position,
                  "question_type" => second_question.question_type,
                  "response_options" => [
                    { "id" => second_question_first_option.id, "body" => second_question_first_option.body },
                    { "id" => second_question_second_option.id, "body" => second_question_second_option.body }
                  ]
                }
              ]
            }
          end

          let(:form) { Decidim::Elections::Admin::QuestionsForm.from_params(update_params).with_context(context_params) }
          let(:command) { described_class.new(form, election) }

          it "updates all fields" do
            command.call
            updated = election.reload.questions.find_by(id: first_question.id)
            expect(translated(updated.body)).to eq("First Q updated")
            expect(translated(updated.description)).to eq("Desc updated")
            expect(translated(updated.response_options.first.body)).to eq("Updated Option")
          end
        end

        context "when updating the order of questions" do
          let(:reorder_params) do
            {
              "questions" => [
                {
                  "id" => first_question.id,
                  "body" => first_question.body,
                  "description" => first_question.description,
                  "position" => 1,
                  "question_type" => first_question.question_type,
                  "response_options" => [
                    { "id" => first_question_first_option.id, "body" => first_question_first_option.body },
                    { "id" => first_question_second_option.id, "body" => first_question_second_option.body }
                  ]
                },
                {
                  "id" => second_question.id,
                  "body" => second_question.body,
                  "description" => second_question.description,
                  "position" => 0,
                  "question_type" => second_question.question_type,
                  "response_options" => [
                    { "id" => second_question_first_option.id, "body" => second_question_first_option.body },
                    { "id" => second_question_second_option.id, "body" => second_question_second_option.body }
                  ]
                }
              ]
            }
          end

          let(:form) { Decidim::Elections::Admin::QuestionsForm.from_params(reorder_params).with_context(context_params) }
          let(:command) { described_class.new(form, election) }

          it "updates order" do
            command.call
            bodies = election.reload.questions.order(:position).map { |q| translated(q.body) }
            expect(bodies).to eq(["Second Q", "First Q"])
          end
        end

        context "when deleting a question" do
          let(:delete_params) do
            {
              "questions" => [
                {
                  "id" => first_question.id,
                  "body" => first_question.body,
                  "description" => first_question.description,
                  "position" => first_question.position,
                  "question_type" => first_question.question_type,
                  "deleted" => true,
                  "response_options" => [
                    { "id" => first_question_first_option.id, "body" => first_question_first_option.body },
                    { "id" => first_question_second_option.id, "body" => first_question_second_option.body }
                  ]
                },
                {
                  "id" => second_question.id,
                  "body" => second_question.body,
                  "description" => second_question.description,
                  "position" => second_question.position,
                  "question_type" => second_question.question_type,
                  "response_options" => [
                    { "id" => second_question_first_option.id, "body" => second_question_first_option.body },
                    { "id" => second_question_second_option.id, "body" => second_question_second_option.body }
                  ]
                }
              ]
            }
          end

          let(:form) { Decidim::Elections::Admin::QuestionsForm.from_params(delete_params).with_context(context_params) }
          let(:command) { described_class.new(form, election) }

          it "removes only the deleted question and keeps the other" do
            expect { command.call }
              .to change { election.reload.questions.count }.from(2).to(1)
            remaining = election.reload.questions.first
            expect(translated(remaining.body)).to eq("Second Q")
            expect(translated(remaining.description)).to eq("Desc 2")
          end
        end

        context "when adding a new question" do
          let(:add_params) do
            {
              "questions" => [
                {
                  "body" => { en: "Brand new Q" },
                  "description" => { en: "Description" },
                  "position" => 2,
                  "question_type" => "multiple_option",
                  "response_options" => [
                    { "body" => { en: "First New Option" } },
                    { "body" => { en: "Second New Option" } }
                  ]
                }
              ]
            }
          end

          let(:form) { Decidim::Elections::Admin::QuestionsForm.from_params(add_params).with_context(context_params) }
          let(:command) { described_class.new(form, election) }

          it "creates a new question and its response options" do
            expect { command.call }
              .to change { election.reload.questions.count }.by(1)
            new_question = election.reload.questions.last
            expect(translated(new_question.body)).to eq("Brand new Q")
            expect(translated(new_question.description)).to eq("Description")
            expect(new_question.response_options.size).to eq(2)
            expect(translated(new_question.response_options.first.body)).to eq("First New Option")
          end
        end

        context "when the form is invalid" do
          let(:form) do
            double("Form", invalid?: true, current_user: current_user, current_organization: organization, questions: [])
          end
          let(:command) { described_class.new(form, election) }

          it "broadcasts :invalid" do
            expect { command.call }
              .to broadcast(:invalid)
          end
        end

        context "when updating, deleting, and adding at once" do
          let(:combo_params) do
            {
              "questions" => [
                {
                  "id" => first_question.id,
                  "body" => { en: "First Q Updated" },
                  "description" => { en: "Desc Updated" },
                  "position" => 1,
                  "question_type" => first_question.question_type,
                  "response_options" => [
                    { "id" => first_question_first_option.id, "body" => { en: "First Option Updated" } },
                    { "id" => first_question_second_option.id, "body" => first_question_second_option.body }
                  ]
                },
                {
                  "id" => second_question.id,
                  "body" => second_question.body,
                  "description" => second_question.description,
                  "position" => 0,
                  "question_type" => second_question.question_type,
                  "deleted" => true,
                  "response_options" => [
                    { "id" => second_question_first_option.id, "body" => second_question_first_option.body },
                    { "id" => second_question_second_option.id, "body" => second_question_second_option.body }
                  ]
                },
                {
                  "body" => { en: "Totally New Q" },
                  "description" => { en: "New Desc" },
                  "position" => 2,
                  "question_type" => "multiple_option",
                  "response_options" => [
                    { "body" => { en: "Brand Opt 1" } },
                    { "body" => { en: "Brand Opt 2" } }
                  ]
                }
              ]
            }
          end

          let(:form) { Decidim::Elections::Admin::QuestionsForm.from_params(combo_params).with_context(context_params) }
          let(:command) { described_class.new(form, election) }

          it "handles all changes in one call" do
            expect { command.call }
              .not_to(change { election.reload.questions.count })
            questions = election.reload.questions.order(:position)
            expect(translated(questions.first.body)).to eq("First Q Updated")
            expect(translated(questions.first.description)).to eq("Desc Updated")
            expect(translated(questions.last.body)).to eq("Totally New Q")
            expect(translated(questions.last.description)).to eq("New Desc")
          end
        end
      end
    end
  end
end
