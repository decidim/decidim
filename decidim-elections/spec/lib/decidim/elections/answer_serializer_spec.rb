# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    describe AnswerSerializer do
      subject do
        described_class.new(answer)
      end

      let!(:answer) { create(:election_answer, :with_votes) }
      let!(:election) { answer.question.election }

      describe "#serialize" do
        let(:serialized) { subject.serialize }

        it "serializes the id" do
          expect(serialized).to include(id: answer.id)
        end

        it "serializes the participatory space" do
          expect(serialized[:participatory_space]).to include(id: election.participatory_space.id)
          I18n.available_locales.each do |locale|
            expect(translated(serialized[:participatory_space][:title], locale: locale)).to eq(translated(election.participatory_space.title, locale: locale))
          end
        end

        it "serializes the title" do
          I18n.available_locales.each do |locale|
            expect(translated(serialized[:answer_title], locale: locale)).to eq(translated(answer.title, locale: locale))
          end
        end

        it "serializes the results total" do
          expect(serialized[:answer_votes]).to eq(answer.results_total)
        end

        it "serializes the election id" do
          expect(serialized[:election_id]).to eq(answer.question.election.id)
        end

        it "serializes the election title" do
          I18n.available_locales.each do |locale|
            expect(translated(serialized[:election_title], locale: locale)).to eq(translated(answer.question.election.title, locale: locale))
          end
        end

        it "serializes the question id" do
          expect(serialized[:question_id]).to eq(answer.question.id)
        end

        it "serializes the question title" do
          I18n.available_locales.each do |locale|
            expect(translated(serialized[:question_title], locale: locale)).to eq(translated(answer.question.title, locale: locale))
          end
        end
      end
    end
  end
end
