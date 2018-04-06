# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    module Admin
      describe PublishConsultation do
        subject { described_class.new(consultation) }

        let(:consultation) { create :consultation, :unpublished }

        context "when the consultation is nil" do
          let(:consultation) { nil }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when the consultation is published" do
          let(:consultation) { create :consultation, :published }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when the consultation is not published" do
          it "is valid" do
            expect { subject.call }.to broadcast(:ok)
          end

          it "publishes it" do
            subject.call
            consultation.reload
            expect(consultation).to be_published
          end
        end
      end
    end
  end
end
