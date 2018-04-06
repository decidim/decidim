# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    module Admin
      describe CreateConsultation do
        subject { described_class.new(form) }

        let(:organization) { create :organization }
        let(:scope) { create :scope, organization: organization }
        let(:start_voting_date) { Time.zone.today }
        let(:end_voting_date) { Time.zone.today + 1.month }
        let(:attachment) { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }
        let(:errors) { double.as_null_object }
        let(:form) do
          instance_double(
            ConsultationForm,
            invalid?: invalid,
            slug: "slug",
            title: { en: "title" },
            subtitle: { en: "subtitle" },
            description: { en: "description" },
            banner_image: attachment,
            highlighted_scope: scope,
            start_voting_date: start_voting_date,
            end_voting_date: end_voting_date,
            introductory_video_url: nil,
            current_organization: organization,
            introductory_image: nil,
            errors: errors
          )
        end
        let(:invalid) { false }

        before do
          Decidim::AttachmentUploader.enable_processing = true
        end

        context "when the form is not valid" do
          let(:invalid) { true }

          it "broadcasts invalid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when the consultation is not persisted" do
          let(:invalid_consultation) do
            instance_double(
              Decidim::Consultation,
              persisted?: false,
              valid?: false,
              errors: {
                banner_image: "Image too big"
              }
            ).as_null_object
          end

          before do
            expect(Decidim::Consultation).to receive(:new).and_return(invalid_consultation)
          end

          it "broadcasts invalid" do
            expect { subject.call }.to broadcast(:invalid)
          end

          it "adds errors to the form" do
            expect(errors).to receive(:add).with(:banner_image, "Image too big")
            subject.call
          end
        end

        context "when everything is ok" do
          it "creates a consultation" do
            expect { subject.call }.to change { Decidim::Consultation.count }.by(1)
          end

          it "broadcasts ok" do
            expect { subject.call }.to broadcast(:ok)
          end
        end
      end
    end
  end
end
