# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    module Admin
      describe CreateQuestion do
        subject { described_class.new(form) }

        let(:organization) { create :organization }
        let(:consultation) { create(:consultation, organization: organization) }
        let(:scope) { create(:scope, organization: organization) }
        let(:errors) { double.as_null_object }
        let(:banner_image) { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }
        let(:hero_image) { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }
        let(:params) do
          {
            question: {
              slug: "slug",
              title_en: "title",
              subtitle_en: "subtitle",
              promoter_group_en: "Promoter group",
              participatory_scope_en: "Participatory scope",
              what_is_decided_en: "What is decided",
              decidim_scope_id: scope.id,
              banner_image: banner_image,
              hero_image: hero_image,
              external_voting: false,
              order: 1
            }
          }
        end
        let(:context) do
          {
            current_organization: consultation.organization,
            current_consultation: consultation
          }
        end
        let(:form) { QuestionForm.from_params(params).with_context(context) }

        context "when the form is not valid" do
          before do
            expect(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when the question is not persisted" do
          let(:invalid_question) do
            instance_double(
              Decidim::Consultations::Question,
              persisted?: false,
              valid?: false,
              errors: {
                banner_image: "Image too big",
                hero_image: "Image too big"
              }
            ).as_null_object
          end

          before do
            expect(form).to receive(:invalid?).and_return(false)
            expect(Decidim::Consultations::Question).to receive(:new).and_return(invalid_question)
          end

          it "broadcasts invalid" do
            expect { subject.call }.to broadcast(:invalid)
          end

          it "adds banner image related errors to the form" do
            subject.call
            expect(form.errors).to have_key :banner_image
          end

          it "adds hero image related errors to the form" do
            subject.call
            expect(form.errors).to have_key :hero_image
          end
        end

        context "when everything is ok" do
          it "creates a question" do
            expect { subject.call }.to change { Decidim::Consultations::Question.count }.by(1)
          end

          it "broadcasts ok" do
            expect { subject.call }.to broadcast(:ok)
          end
        end
      end
    end
  end
end
