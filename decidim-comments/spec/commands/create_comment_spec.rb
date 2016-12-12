# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Comments
    describe CreateComment, :db do
      describe "call" do
        let(:organization) { create(:organization) }
        let(:author) { create(:user, organization: organization) }
        let(:participatory_process) { create :participatory_process, organization: organization }
        let(:form_params) do
          {
            "comment" => {
              "body" => ::Faker::Lorem.paragraph
            }
          }
        end
        let(:form) do
          CommentForm.from_params(
            form_params
          )
        end
        let(:command) { described_class.new(form, author, participatory_process) }

        describe "when the form is not valid" do
          before do
            expect(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't create a comment" do
            expect do
              command.call
            end.to_not change { Comment.count }
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new comment" do
            expect do
              command.call
            end.to change { Comment.count }.by(1)
          end
        end
      end
    end
  end
end
