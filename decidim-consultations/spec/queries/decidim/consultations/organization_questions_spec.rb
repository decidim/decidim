# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    describe OrganizationQuestions do
      subject { described_class.new(organization) }

      let!(:organization) { create(:organization) }
      let!(:local_consultation) { create :consultation, organization: }
      let!(:local_questions) do
        create_list(:question, 3, consultation: local_consultation)
      end

      let!(:foreign_consultation) { create :consultation }
      let!(:foreign_questions) do
        create_list(:question, 3, consultation: foreign_consultation)
      end

      describe "query" do
        it "includes the organization's questions" do
          expect(subject).to include(*local_questions)
        end

        it "excludes the foreign questions" do
          expect(subject).not_to include(*foreign_questions)
        end

        it "Using sugar syntax method for returns the same result as using the constructor and query methods combined" do
          expect(subject.query).to eq(described_class.for(organization))
        end
      end
    end
  end
end
