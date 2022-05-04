# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    module Admin
      describe UpdateResponse do
        let(:response) { create :response }
        let(:params) do
          {
            response: {
              id: response.id,
              title_en: "Foo title",
              title_ca: "Foo title",
              title_es: "Foo title"
            }
          }
        end
        let(:context) do
          {
            current_organization: response.question.organization,
            current_question: response.question
          }
        end
        let(:form) { ResponseForm.from_params(params).with_context(context) }
        let(:command) { described_class.new(response, form) }

        describe "when the form is not valid" do
          before do
            allow(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't update the response" do
            command.call
            response.reload

            expect(response.title["en"]).not_to eq("Foo title")
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "updates the response" do
            expect { command.call }.to broadcast(:ok)
            response.reload

            expect(response.title["en"]).to eq("Foo title")
          end
        end
      end
    end
  end
end
