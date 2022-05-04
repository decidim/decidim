# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    module Admin
      describe UpdateQuestion do
        let(:question) { create :question }
        let(:params) do
          {
            question: {
              id: question.id,
              slug: "slug",
              title_en: "Foo title",
              title_ca: "Foo title",
              title_es: "Foo title",
              subtitle_en: question.subtitle["en"],
              subtitle_ca: question.subtitle["ca"],
              subtitle_es: question.subtitle["es"],
              what_is_decided_en: question.what_is_decided["en"],
              what_is_decided_ca: question.what_is_decided["ca"],
              what_is_decided_es: question.what_is_decided["es"],
              promoter_group_en: question.promoter_group["en"],
              promoter_group_ca: question.promoter_group["ca"],
              promoter_group_es: question.promoter_group["es"],
              participatory_scope_en: question.participatory_scope["en"],
              participatory_scope_ca: question.participatory_scope["ca"],
              participatory_scope_es: question.participatory_scope["es"],
              question_context_en: question.question_context["en"],
              question_context_ca: question.question_context["ca"],
              question_context_es: question.question_context["es"],
              banner_image: question.banner_image.blob,
              hero_image: question.hero_image.blob,
              hashtag: question.hashtag,
              decidim_scope_id: question.scope.id,
              order: question.order
            }
          }
        end
        let(:context) do
          {
            current_organization: question.consultation.organization,
            current_consultation: question.consultation
          }
        end
        let(:form) { QuestionForm.from_params(params).with_context(context) }
        let(:command) { described_class.new(question, form) }

        describe "when the form is not valid" do
          before do
            allow(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't update the consultation" do
            command.call
            question.reload

            expect(question.title["en"]).not_to eq("Foo title")
          end
        end

        describe "when the question is not valid" do
          before do
            allow(form).to receive(:invalid?).and_return(false)
            expect(question).to receive(:valid?).at_least(:once).and_return(false)
            question.errors.add(:banner_image, "File resolution is too large")
            question.errors.add(:hero_image, "File resolution is too large")
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "adds errors to the form" do
            command.call

            expect(form.errors[:banner_image]).not_to be_empty
            expect(form.errors[:hero_image]).not_to be_empty
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "updates the question" do
            expect { command.call }.to broadcast(:ok)
            question.reload

            expect(question.title["en"]).to eq("Foo title")
          end
        end
      end
    end
  end
end
