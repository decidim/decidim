# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    module Admin
      describe UpdateResponseGroup do
        let(:response_group) { create :response_group }
        let(:params) do
          {
            response_group: {
              id: response_group.id,
              title_en: "Foo title",
              title_ca: "Foo title",
              title_es: "Foo title"
            }
          }
        end
        let(:context) do
          {
            current_organization: response_group.question.organization,
            current_question: response_group.question
          }
        end
        let(:form) { ResponseGroupForm.from_params(params).with_context(context) }
        let(:command) { described_class.new(response_group, form) }

        describe "when the form is not valid" do
          before do
            allow(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't update the response group" do
            command.call
            response_group.reload

            expect(response_group.title["en"]).not_to eq("Foo title")
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "updates the response group" do
            expect { command.call }.to broadcast(:ok)
            response_group.reload

            expect(response_group.title["en"]).to eq("Foo title")
          end
        end
      end
    end
  end
end
