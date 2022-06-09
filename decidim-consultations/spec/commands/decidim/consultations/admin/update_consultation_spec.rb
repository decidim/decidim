# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    module Admin
      describe UpdateConsultation do
        let(:consultation) { create :consultation }
        let(:params) do
          {
            consultation: {
              id: consultation.id,
              title_en: "Foo title",
              title_ca: "Foo title",
              title_es: "Foo title",
              subtitle_en: consultation.subtitle["en"],
              subtitle_ca: consultation.subtitle["ca"],
              subtitle_es: consultation.subtitle["es"],
              description_en: consultation.description["en"],
              description_ca: consultation.description["ca"],
              description_es: consultation.description["es"],
              slug: consultation.slug,
              decidim_highlighted_scope_id: consultation.highlighted_scope.id,
              start_voting_date: consultation.start_voting_date,
              end_voting_date: consultation.end_voting_date,
              introductory_video_url: consultation.introductory_video_url
            }.merge(attachment_params)
          }
        end
        let(:attachment_params) do
          {
            banner_image: consultation.banner_image.blob,
            introductory_image: consultation.introductory_image.blob
          }
        end
        let(:context) do
          {
            current_organization: consultation.organization,
            consultation_id: consultation.id
          }
        end
        let(:form) { ConsultationForm.from_params(params).with_context(context) }
        let(:command) { described_class.new(consultation, form) }

        describe "when the form is not valid" do
          before do
            allow(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't update the consultation" do
            command.call
            consultation.reload

            expect(consultation.title["en"]).not_to eq("Foo title")
          end
        end

        describe "when the consultation is not valid" do
          before do
            allow(form).to receive(:invalid?).and_return(false)
            expect(consultation).to receive(:valid?).at_least(:once).and_return(false)
            consultation.errors.add(:banner_image, "File resolution is too large")
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "adds errors to the form" do
            command.call

            expect(form.errors[:banner_image]).not_to be_empty
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "updates the consultation" do
            expect { command.call }.to broadcast(:ok)
            consultation.reload

            expect(consultation.title["en"]).to eq("Foo title")
          end

          context "when banner image is not updated" do
            let(:attachment_params) do
              {
                introductory_image: consultation.introductory_image.blob
              }
            end

            it "does not replace the banner image" do
              expect(consultation).not_to receive(:banner_image=)

              command.call
              consultation.reload

              expect(consultation.banner_image).to be_present
            end
          end

          context "when introductory image is not updated" do
            let(:attachment_params) do
              {
                banner_image: consultation.banner_image.blob
              }
            end

            it "does not replace the introductory image" do
              expect(consultation).not_to receive(:introductory_image=)

              command.call
              consultation.reload

              expect(consultation.introductory_image).to be_present
            end
          end
        end
      end
    end
  end
end
