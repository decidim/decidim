# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    module Admin
      describe CreateResponse do
        subject { described_class.new(form) }

        let(:question) { create :question }
        let(:errors) { double.as_null_object }
        let(:params) do
          {
            response: {
              title_en: "title"
            }
          }
        end
        let(:context) do
          {
            current_organization: question.organization,
            current_question: question
          }
        end
        let(:form) { ResponseForm.from_params(params).with_context(context) }

        context "when the form is not valid" do
          before do
            allow(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when everything is ok" do
          it "creates a response" do
            expect { subject.call }.to change(Decidim::Consultations::Response, :count).by(1)
          end

          it "broadcasts ok" do
            expect { subject.call }.to broadcast(:ok)
          end
        end
      end
    end
  end
end
