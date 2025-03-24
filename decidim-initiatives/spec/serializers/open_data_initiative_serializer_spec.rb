# frozen_string_literal: true

require "spec_helper"

module Decidim::Initiatives
  describe OpenDataInitiativeSerializer do
    subject { described_class.new(initiative) }

    let(:initiative) { create(:initiative, :with_area) }
    let(:serialized) { subject.serialize }

    describe "#serialize" do
      it "includes the reference" do
        expect(serialized).to include(reference: initiative.reference)
      end

      it "includes the title" do
        expect(serialized).to include(title: initiative.title)
      end

      it "includes the url" do
        expect(serialized).to include(url: "http://#{initiative.organization.host}:#{Capybara.server_port}/#{I18n.locale}/initiatives/i-#{initiative.id}")
      end

      it "includes the description" do
        expect(serialized).to include(description: initiative.description)
      end

      it "includes the state" do
        expect(serialized).to include(state: initiative.state)
      end

      it "includes the created_at timestamp" do
        expect(serialized).to include(created_at: initiative.created_at)
      end

      it "includes the updated_at timestamp" do
        expect(serialized).to include(updated_at: initiative.updated_at)
      end

      it "includes the published_at timestamp" do
        expect(serialized).to include(published_at: initiative.published_at)
      end

      it "includes the signature_start_date" do
        expect(serialized).to include(signature_start_date: initiative.signature_start_date)
      end

      it "includes the signature_end_date" do
        expect(serialized).to include(signature_end_date: initiative.signature_end_date)
      end

      it "includes the signature_type" do
        expect(serialized).to include(signature_type: initiative.signature_type)
      end

      it "includes the number of signatures (supports)" do
        expect(serialized).to include(signatures: initiative.supports_count)
      end

      it "includes the answer" do
        expect(serialized).to include(answer: initiative.answer)
      end

      it "includes the answered_at" do
        expect(serialized).to include(answered_at: initiative.answered_at)
      end

      it "includes the answer_url" do
        expect(serialized).to include(answer_url: initiative.answer_url)
      end

      it "includes the hashtag" do
        expect(serialized).to include(hashtag: initiative.hashtag)
      end

      it "includes the first_progress_notification_at timestamp" do
        expect(serialized).to include(first_progress_notification_at: initiative.first_progress_notification_at)
      end

      it "includes the second_progress_notification_at timestamp" do
        expect(serialized).to include(second_progress_notification_at: initiative.second_progress_notification_at)
      end

      it "includes the online_votes" do
        expect(serialized).to include(online_votes: initiative.online_votes)
      end

      it "includes the offline_votes" do
        expect(serialized).to include(offline_votes: initiative.offline_votes)
      end

      it "includes the comments_count" do
        expect(serialized).to include(comments_count: initiative.comments_count)
      end

      it "includes the follows_count" do
        expect(serialized).to include(follows_count: initiative.follows_count)
      end

      it "includes the scope id" do
        expect(serialized[:scope]).to include(id: initiative.scope.id)
      end

      it "includes the scope name" do
        expect(serialized[:scope]).to include(name: initiative.scope.name)
      end

      it "includes the type id" do
        expect(serialized[:type]).to include(id: initiative.type.id)
      end

      it "includes the type title" do
        expect(serialized[:type]).to include(title: initiative.type.title)
      end

      it "includes the authors' ids" do
        expect(serialized[:authors]).to include(id: initiative.author_users.map(&:id))
      end

      it "includes the authors' names" do
        expect(serialized[:authors]).to include(name: initiative.author_users.map(&:name))
      end

      it "includes the area id" do
        expect(serialized[:area]).to include(id: initiative.area.id)
      end

      it "includes the area name" do
        expect(serialized[:area]).to include(name: initiative.area.name)
      end
    end
  end
end
