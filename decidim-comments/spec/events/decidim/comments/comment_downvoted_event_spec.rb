# frozen_string_literal: true

require "spec_helper"

describe Decidim::Comments::CommentDownvotedEvent do
  let(:event_name) { "decidim.events.comments.comment_downvoted" }
  let(:weight) { -1 }

  context "with leaf comment" do
    it_behaves_like "a comment voted event" do
      let(:parent_comment) { create(:comment) }
      let(:comment) { create :comment, commentable: parent_comment, root_commentable: parent_comment.root_commentable }
      let(:resource_title) { decidim_html_escape(translated(resource.commentable.title)) }
      let(:resource_path) { resource_locator(resource.commentable).path }
    end
  end

  context "with root comment" do
    it_behaves_like "a comment voted event" do
      let(:resource) { comment.commentable }
      let(:comment) { create :comment }
      let(:resource_title) { decidim_html_escape(translated(resource.title)) }

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
              expect(subject.perform_translation?).to eq(false)
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
                expect(subject.perform_translation?).to eq(false)
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
              expect(subject.perform_translation?).to eq(false)
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
                expect(subject.perform_translation?).to eq(false)
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
                expect(subject.safe_resource_translated_text).to eq("<div><p>#{comment.body["en"]}</p></div>")
              end
            end
          end
        end
      end
    end
  end
end
