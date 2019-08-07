# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    module Admin
      describe UnpublishQuestion do
        subject { described_class.new(question) }

        let(:question) { create :question, :published }

        context "when the question is nil" do
          let(:question) { nil }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when the question is not published" do
          let(:question) { create :question, :unpublished }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when the question is published" do
          it "is valid" do
            expect { subject.call }.to broadcast(:ok)
          end

          it "unpublishes it" do
            subject.call
            question.reload
            expect(question).not_to be_published
          end
        end
      end
    end
  end
end
