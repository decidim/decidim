# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    module Admin
      describe CreateResponseGroup do
        subject { described_class.new(form) }

        let(:question) { create :question }
        let(:params) do
          {
            response_group: {
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
        let(:form) { ResponseGroupForm.from_params(params).with_context(context) }

        context "when the form is not valid" do
          before do
            allow(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when everything is ok" do
          it "creates a response group" do
            expect { subject.call }.to change(Decidim::Consultations::ResponseGroup, :count).by(1)
          end

          it "broadcasts ok" do
            expect { subject.call }.to broadcast(:ok)
          end
        end
      end
    end
  end
end
