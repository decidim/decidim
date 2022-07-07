# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Events
    describe AuthorEvent do
      subject { dummy_event }

      let(:dummy_event) do
        class DummyEvent < Decidim::Events::SimpleEvent
          include Decidim::Events::AuthorEvent

          def default_i18n_options
            {}
          end
        end

        DummyEvent.new(resource: resource, event_name: "dummy_event", user: user, extra: {})
      end

      let(:resource) do
        OpenStruct.new(author: user)
      end

      let(:user) { create(:user) }

      it "adds author i18n attributes" do
        expect(subject.i18n_options.keys).to include(:author_name)
        expect(subject.i18n_options.keys).to include(:author_nickname)
        expect(subject.i18n_options.keys).to include(:author_path)
        expect(subject.i18n_options.keys).to include(:author_url)
      end

      it "delegates the author to the resource" do
        expect(subject.author).to eq(resource.author)
      end

      it "has an author nickname" do
        expect(subject.author_nickname).to be_present
        expect(subject.author_nickname).to include(user.nickname)
      end

      it "has an author name" do
        expect(subject.author_name).to be_present
        expect(subject.author_name).to include(user.name)
      end

      it "has an author path" do
        expect(subject.author_path).to be_present
        expect(subject.author_path).to start_with("/profile")
      end

      it "has an author url" do
        expect(subject.author_url).to be_present
        expect(subject.author_url).to start_with("http://")
      end

      context "when the resource is missing its author" do
        let(:user) { nil }

        it "has an empty author nickname" do
          expect(subject.author_nickname).to eq("")
        end

        it "has an empty author name" do
          expect(subject.author_name).to eq("")
        end

        it "has an empty author path" do
          expect(subject.author_path).to eq("")
        end

        it "has an empty author url" do
          expect(subject.author_url).to eq("")
        end
      end

      context "when the author is not a user" do
        let(:user) { create(:organization) }

        it "has an empty author nickname" do
          expect(subject.author_nickname).to eq("")
        end

        it "has an empty author name" do
          expect(subject.author_name).to eq("")
        end

        it "has an empty author path" do
          expect(subject.author_path).to eq("")
        end

        it "has an empty author url" do
          expect(subject.author_url).to eq("")
        end
      end

      context "when the resource doesn't have an author" do
        let(:resource) { OpenStruct.new }

        it "ignores it" do
          expect(subject.author).to be_nil
        end
      end
    end
  end
end
