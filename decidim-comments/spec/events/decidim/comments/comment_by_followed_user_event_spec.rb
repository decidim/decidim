# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe CommentByFollowedUserEvent do
      include_context "when it's a comment event"
      let(:author) { comment.author }
      let(:resource) { comment.root_commentable }
      let(:event_name) { "decidim.events.comments.comment_by_followed_user" }

      it_behaves_like "a comment event"

      describe "email_subject" do
        it "is generated correctly" do
          expect(subject.email_subject).to eq("There is a new comment by #{author_name} in #{resource_title}")
        end
      end

      describe "email_intro" do
        it "is generated correctly" do
          expect(subject.email_intro)
            .to eq("#{author_name} has left a comment in #{resource_title}. You can read it in this page:")
        end
      end

      describe "email_outro" do
        it "is generated correctly" do
          expect(subject.email_outro)
            .to include("You have received this notification because you are following #{author_name}")
        end
      end

      describe "notification_title" do
        it "is generated correctly" do
          expect(subject.notification_title)
            .to start_with("There is a new comment by <a href=\"#{author_path}\">#{author_name} #{author_nickname}</a> in")
          expect(subject.notification_title)
            .to end_with("<a href=\"#{resource_path}#comment_#{comment.id}\">#{resource_title}</a>.")
        end
      end

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
            expect(subject.safe_resource_text).to eq(subject.resource_text)
          end

          it "does not offer an alternate translation" do
            expect(subject.safe_resource_text).to eq("<div><p>#{comment.body["en"]}</p></div>")
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

          around do |example|
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
              expect(subject.safe_resource_text).to eq("<div><p>#{comment.body["en"]}</p></div>")
            end

            it "does not offer an alternate translation" do
              expect(subject.safe_resource_translated_text).to eq("<div><p>#{comment.body["machine_translations"]["ca"]}</p></div>")
            end

            context "when translation is not available" do
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
                expect(subject.safe_resource_text).to eq("<div><p>#{comment.body["en"]}</p></div>")
              end

              it "does not offer an alternate translation" do
                expect(subject.safe_resource_translated_text).to eq("<div><p>#{comment.body["en"]}</p></div>")
              end
            end
          end

          context "when priority is translation" do
            let(:comment) do
              create :comment, body: { "en": "This is Sparta!", "machine_translations": { "ca": "C'est Sparta!" } }
            end

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
              expect(subject.safe_resource_text).to eq("<div><p>#{comment.body["en"]}</p></div>")
            end

            it "does not offer an alternate translation" do
              expect(subject.safe_resource_translated_text).to eq("<div><p>#{comment.body["machine_translations"]["ca"]}</p></div>")
            end

            context "when translation is not available" do
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
                expect(subject.safe_resource_text).to eq("<div><p>#{comment.body["en"]}</p></div>")
              end

              it "does not offer an alternate translation" do
                expect(subject.safe_resource_translated_text).to eq("<div><p>#{comment.body["en"]}</p></div>")
              end
            end
          end
        end
      end
    end
  end
end
