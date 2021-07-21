# frozen_string_literal: true

require "spec_helper"

describe Decidim::Comments::UserMentionedEvent do
  let(:event_name) { "decidim.events.comments.user_mentioned" }


  include_context "when it's a comment event"

  let(:body) { "Comment mentioning some user, @#{comment.author.nickname}" }
  let(:ca_body) { "Un commentaire pour @#{comment.author.nickname}" }
  let(:parsed_body) { Decidim::ContentProcessor.parse(body, current_organization: comment.organization)}
  let(:parsed_ca_body) { Decidim::ContentProcessor.parse(ca_body, current_organization: comment.organization) }
  let(:comment_body) {  { en: parsed_body.rewrite, "machine_translations": { "ca": parsed_ca_body.rewrite } } }
  before do
    comment.body = comment_body
    comment.save
  end

  it_behaves_like "a comment event"

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("You have been mentioned in #{translated resource.title}")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro).to eq("You have been mentioned")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to eq("You have received this notification because you have been mentioned in #{translated resource.title}.")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to include("You have been mentioned in <a href=\"#{resource_path}#comment_#{comment.id}\">#{translated resource.title}</a>")

      expect(subject.notification_title)
        .to include(" by <a href=\"/profiles/#{comment_author.nickname}\">#{comment_author.name} @#{comment_author.nickname}</a>")
    end
  end

  describe "resource_text" do
    it "correctly renders comments with mentions" do
      expect(subject.resource_text).not_to include("gid://")
      expect(subject.resource_text).to include("@#{comment.author.nickname}")
    end
  end

  let(:author_link) { "<a class=\"user-mention\" href=\"http://#{organization.host}/profiles/#{comment_author.nickname}\">@#{comment_author.nickname}</a>"}
  let(:en_comment_content) { "<div><p>Comment mentioning some user, #{author_link}</p></div>"}
  let(:ca_comment_content) { "<div><p>Un commentaire pour #{author_link}</p></div>"}

  describe "translated notifications" do
    context "when it is not machine machine translated" do

      let(:comment) do
        create :comment, body: { "en": "This is Sparta!", "machine_translations": { "ca": "C'est Sparta!" } }
      end

      before do
        organization = comment.organization
        organization.update enable_machine_translations: false
      end

      it "does not have machine translations" do
        expect(subject.perform_translation?).to eq(false)
      end

      it "does not have machine translations" do
        expect(subject.translation_missing?).to eq(false)
      end

      it "does not have machine translations" do
        expect(subject.content_in_same_language?).to eq(false)
      end

      it "does not offer an alternate translation" do
        expect(subject.safe_resource_text).to eq(subject.resource_text )
      end

      it "does not offer an alternate translation" do
        expect(subject.safe_resource_text).to eq(en_comment_content)
      end
    end

    context "when is machine machine translated" do
      let(:user) { create :user, organization: organization, locale: "ca" }

      let(:comment) do
        create :comment, body: { "en": "This is Sparta!", "machine_translations": { "ca": "C'est Sparta!" } }
      end

      before do
        organization = comment.organization
        organization.update enable_machine_translations: true
      end

      around(:each) do |example|
        I18n.with_locale(user.locale) { example.run }
      end

      context "when priority is original" do
        before do
          organization.update machine_translation_display_priority: "original"
        end

        it "does not have machine translations" do
          expect(subject.perform_translation?).to eq(true)
        end

        it "does not have machine translations" do
          expect(subject.translation_missing?).to eq(false)
        end

        it "does not have machine translations" do
          expect(subject.content_in_same_language?).to eq(false)
        end

        it "does not offer an alternate translation" do
          expect(subject.safe_resource_text).to eq(en_comment_content)
        end

        it "does not offer an alternate translation" do
          expect(subject.safe_resource_translated_text).to eq("<div><p>#{comment.body["machine_translations"]["ca"]}</p></div>")
        end

        context "when translation is not available" do
          let(:comment_body) {  { en: parsed_body.rewrite } }
          let(:comment) do
            create :comment, body: { "en": "This is Sparta!" }
          end
          it "does not have machine translations" do
            expect(subject.perform_translation?).to eq(true)
          end

          it "does not have machine translations" do
            expect(subject.translation_missing?).to eq(true)
          end

          it "does not have machine translations" do
            expect(subject.content_in_same_language?).to eq(false)
          end

          it "does not offer an alternate translation" do
            expect(subject.safe_resource_text).to eq(en_comment_content)
          end

          it "does not offer an alternate translation" do
            expect(subject.safe_resource_translated_text).to eq(en_comment_content)
          end
        end
      end

      context "when priority is translation" do
        let(:comment) { create :comment, body: { "en": "This is Sparta!", "machine_translations": { "ca": "C'est Sparta!" } } }
        let(:comment_body) {  { en: parsed_body.rewrite, "machine_translations": { "ca": parsed_ca_body.rewrite } } }

        before do
          organization.update machine_translation_display_priority: "translation"
        end

        it "does not have machine translations" do
          expect(subject.perform_translation?).to eq(true)
        end

        it "does not have machine translations" do
          expect(subject.translation_missing?).to eq(false)
        end

        it "does not have machine translations" do
          expect(subject.content_in_same_language?).to eq(false)
        end

        it "does not offer an alternate translation" do
          expect(subject.safe_resource_text).to eq(en_comment_content)
        end

        it "does not offer an alternate translation" do
          expect(subject.safe_resource_translated_text).to eq("<div><p>#{comment.body["machine_translations"]["ca"]}</p></div>")
        end

        context "when translation is not available" do
          let(:comment_body) { { en: parsed_body.rewrite } }
          let(:comment) { create :comment }

          it "does not have machine translations" do
            expect(subject.perform_translation?).to eq(true)
          end

          it "does not have machine translations" do
            expect(subject.translation_missing?).to eq(true)
          end

          it "does not have machine translations" do
            expect(subject.content_in_same_language?).to eq(false)
          end

          it "does not offer an alternate translation" do
            expect(subject.safe_resource_text).to eq(en_comment_content)
          end

          it "does not offer an alternate translation" do
            expect(subject.safe_resource_translated_text).to eq(en_comment_content)
          end

        end
      end
    end
  end
end
