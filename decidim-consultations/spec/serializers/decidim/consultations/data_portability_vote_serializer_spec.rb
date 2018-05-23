# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    describe DataPortabilityVoteSerializer do
      let(:subject) { described_class.new(resource) }

      let(:organization) { create(:organization) }
      let(:user) { create :user, :confirmed, organization: organization }
      let(:consultation) { create(:consultation, :published, :upcoming, organization: organization) }
      let(:question) { create :question, :published, consultation: consultation }
      let(:resource) { create :vote, author: user, question: question }

      let(:serialized) { subject.serialize }

      describe "#serialize" do
        it "includes the id" do
          expect(serialized).to include(id: resource.id)
        end

        it "includes the question" do
          expect(serialized[:question]).to include(id: resource.question.id)
          expect(serialized[:question]).to include(title: resource.question.title)
          expect(serialized[:question]).to include(subtitle: resource.question.subtitle)
          expect(serialized[:question]).to include(what_is_decided: resource.question.what_is_decided)
          expect(serialized[:question]).to include(promoter_group: resource.question.promoter_group)
          expect(serialized[:question]).to include(participatory_scope: resource.question.participatory_scope)
          expect(serialized[:question]).to include(question_context: resource.question.question_context)
          expect(serialized[:question]).to include(published_at: resource.question.published_at)
          expect(serialized[:question]).to include(created_at: resource.question.created_at)
          expect(serialized[:question]).to include(updated_at: resource.question.updated_at)
        end

        it "includes the consultation" do
          expect(serialized[:question][:consultation]).to include(id: resource.question.consultation.id)
          expect(serialized[:question][:consultation]).to include(slug: resource.question.consultation.slug)
          expect(serialized[:question][:consultation]).to include(title: resource.question.consultation.title)
          expect(serialized[:question][:consultation]).to include(subtitle: resource.question.consultation.subtitle)
          expect(serialized[:question][:consultation]).to include(description: resource.question.consultation.description)
          expect(serialized[:question][:consultation]).to include(introductory_video_url: resource.question.consultation.introductory_video_url)
          expect(serialized[:question][:consultation]).to include(start_voting_date: resource.question.consultation.start_voting_date)
          expect(serialized[:question][:consultation]).to include(end_voting_date: resource.question.consultation.end_voting_date)
          expect(serialized[:question][:consultation]).to include(results_published_at: resource.question.consultation.results_published_at)
        end

        it "includes the response" do
          expect(serialized[:response]).to include(id: resource.response.id)
          expect(serialized[:response]).to include(title: resource.response.title)
          expect(serialized[:response]).to include(created_at: resource.response.created_at)
          expect(serialized[:response]).to include(updated_at: resource.response.updated_at)
        end

        it "includes the created at" do
          expect(serialized).to include(created_at: resource.created_at)
        end

        it "includes the updated at" do
          expect(serialized).to include(updated_at: resource.updated_at)
        end
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Consultations
    class DataPortabilityVoteSerializer < Decidim::Exporters::Serializer
      # Serializes a Vore for data portability
      def serialize
        {
          id: resource.id,
          question: {
            id: resource.question.id,
            title: resource.question.title,
            subtitle: resource.question.subtitle,
            what_is_decided: resource.question.what_is_decided,
            promoter_group: resource.question.promoter_group,
            participatory_scope: resource.question.participatory_scope,
            question_context: resource.question.question_context,
            published_at: resource.question.published_at,
            created_at: resource.question.created_at,
            updated_at: resource.question.updated_at,
            consultation: {
              id: resource.question.consultation.id,
              slug: resource.question.consultation.slug,
              title: resource.question.consultation.title,
              subtitle: resource.question.consultation.subtitle,
              description: resource.question.consultation.description,
              introductory_video_url: resource.question.consultation.introductory_video_url,
              start_voting_date: resource.question.consultation.start_voting_date,
              end_voting_date: resource.question.consultation.end_voting_date,
              results_published_at: resource.question.consultation.results_published_at
            }
          },
          response: {
            id: resource.response.id,
            title: resource.response.title,
            created_at: resource.response.created_at,
            updated_at: resource.response.updated_at
          },
          created_at: resource.created_at,
          updated_at: resource.updated_at
        }
      end
    end
  end
end
