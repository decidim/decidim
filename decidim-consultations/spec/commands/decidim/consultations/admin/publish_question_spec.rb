# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    module Admin
      describe PublishQuestion do
        subject { described_class.new(question) }

        let(:question) { create :question, :unpublished }

        context "when the consultation is nil" do
          let(:question) { nil }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when the question is published" do
          let(:question) { create :question, :published }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when the question is not published" do
          it "is valid" do
            expect { subject.call }.to broadcast(:ok)
          end

          it "publishes it" do
            subject.call
            question.reload
            expect(question).to be_published
          end
        end
      end
    end
  end
end
