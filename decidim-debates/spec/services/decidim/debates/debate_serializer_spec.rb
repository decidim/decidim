# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Debates
    describe DebateSerializer do
      subject do
        described_class.new(debate)
      end

      let!(:debate) { create(:debate, :with_author) }
      let!(:category) { create(:category, participatory_space: component.participatory_space) }
      let(:participatory_process) { component.participatory_space }
      let(:component) { debate.component }

      before do
        debate.update!(category: category)
      end

      describe "#serialize" do
        let(:serialized) { subject.serialize }

        it "serializes the id" do
          expect(serialized).to include(id: debate.id)
        end

        it "serializes the author profile url" do
          expect(serialized[:author_url]).to match(%r{http.*/profiles})
        end

        context "when there is no author id" do
          it "serializes the author id with nilll" do
            debate.author = nil
            expect(serialized).to include(author_url: "")
          end
        end

        it "serializes the title" do
          expect(serialized).to include(title: debate.title)
        end

        it "serializes the description" do
          expect(serialized).to include(description: debate.description)
        end

        it "serializes the amount of comments" do
          expect(serialized).to include(comments: debate.comments.count)
        end

        it "serializes the date of creation" do
          expect(serialized).to include(created_at: debate.created_at)
        end

        context "when start and end time are set" do
          it "serializes the start and time" do
            debate.start_time = 1.day.ago
            debate.end_time = 1.day.from_now
            expect(serialized).to include(start_time: debate.start_time)
            expect(serialized).to include(end_time: debate.end_time)
          end
        end

        context "when start and end time are not set" do
          it "serializes the start and time as nilll" do
            debate.start_time = nil
            debate.end_time = nil
            expect(serialized).to include(start_time: nil)
            expect(serialized).to include(end_time: nil)
          end
        end

        it "serializes the url" do
          expect(serialized[:url]).to include("http", debate.id.to_s)
        end

        it "serializes the component" do
          expect(serialized[:component]).to include(id: debate.component.id)
        end

        it "serializes the participatory space" do
          expect(serialized[:participatory_space]).to include(id: participatory_process.id)
          expect(serialized[:participatory_space][:url]).to include("http", participatory_process.slug)
        end
      end
    end
  end
end
