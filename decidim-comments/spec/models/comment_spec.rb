# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe Comment do
      let(:component) { create(:component, manifest_name: "dummy") }
      let!(:commentable) { create(:dummy_resource, component:) }
      let!(:author) { create(:user, organization: commentable.organization) }
      let!(:comment) { create(:comment, commentable:, author:) }
      let!(:replies) { create_list(:comment, 3, commentable: comment, root_commentable: commentable) }
      let!(:up_vote) { create(:comment_vote, :up_vote, comment:) }
      let!(:down_vote) { create(:comment_vote, :down_vote, comment:) }

      include_examples "authorable" do
        subject { comment }
      end

      include_examples "reportable" do
        subject { comment }
      end

      it "is valid" do
        expect(comment).to be_valid
      end

      it "is valid with a string as the body" do
        new_comment = build(:comment, body: "Hey this is a comment")
        expect(new_comment).to be_valid
        expect(new_comment.body).to eq("en" => "Hey this is a comment")
      end

      it "is valid with a hash as the body" do
        new_comment = build(:comment, body: { en: "Hey this is a comment" })
        expect(new_comment).to be_valid
        expect(new_comment.body).to eq("en" => "Hey this is a comment")
      end

      it "has an associated commentable" do
        expect(comment.commentable).to eq(commentable)
      end

      it "has an associated root commentable" do
        expect(comment.root_commentable).to eq(commentable)
      end

      it "has a up_votes association returning comment votes with weight 1" do
        expect(comment.up_votes.count).to eq(1)
        expect(comment.up_votes_count).to eq(1)
      end

      it "has a down_votes association returning comment votes with weight -1" do
        expect(comment.down_votes.count).to eq(1)
        expect(comment.down_votes_count).to eq(1)
      end

      it "has an associated participatory_process" do
        expect(comment.participatory_space).to eq(component.participatory_space)
      end

      it "is valid if its parent is a comment and can accept new comments" do
        allow(comment.root_commentable).to receive(:accepts_new_comments?).and_return(true)
        expect(replies[0]).to be_valid
      end

      it "computes its depth before saving the model" do
        expect(comment.depth).to eq(0)
        comment.comments.each do |reply|
          expect(reply.depth).to eq(1)
        end
      end

      describe "#accepts_new_comments?" do
        it "returns true if the comment's depth is below MAX_DEPTH" do
          comment.depth = Comment::MAX_DEPTH - 1
          expect(comment).to be_accepts_new_comments
        end

        it "returns false if the comment's depth is equal or greater than MAX_DEPTH" do
          comment.depth = Comment::MAX_DEPTH
          expect(comment).not_to be_accepts_new_comments
        end
      end

      it "is not valid if alignment is not 0, 1 or -1" do
        comment.alignment = 2
        expect(comment).not_to be_valid
      end

      describe "#visible?" do
        subject { comment.visible? }

        context "when component is not published" do
          before do
            allow(component).to receive(:published?).and_return(false)
          end

          it { is_expected.not_to be_truthy }
        end

        context "when participatory space is visible" do
          before do
            allow(component.participatory_space).to receive(:visible?).and_return(false)
          end

          it { is_expected.not_to be_truthy }
        end
      end

      describe "#up_voted_by?" do
        let(:user) { create(:user, organization: comment.organization) }

        it "returns true if the given user has upvoted the comment" do
          create(:comment_vote, comment:, author: user, weight: 1)
          expect(comment).to be_up_voted_by(user)
        end

        it "returns false if the given user has not upvoted the comment" do
          expect(comment).not_to be_up_voted_by(user)
        end
      end

      describe "#down_voted_by?" do
        let(:user) { create(:user, organization: comment.organization) }

        it "returns true if the given user has downvoted the comment" do
          create(:comment_vote, comment:, author: user, weight: -1)
          expect(comment).to be_down_voted_by(user)
        end

        it "returns false if the given user has not downvoted the comment" do
          expect(comment).not_to be_down_voted_by(user)
        end
      end

      describe "#reported_content_url" do
        subject { comment.reported_content_url }

        let(:url_format) { "http://%{host}:%{port}/processes/%{slug}/f/%{component_id}/dummy_resources/%{resource_id}#comment_%{comment_id}" }

        it "returns the resource URL" do
          expect(subject).to eq(
            format(
              url_format,
              host: commentable.organization.host,
              port: Capybara.server_port,
              slug: commentable.participatory_space.slug,
              component_id: commentable.component.id,
              resource_id: commentable.id,
              comment_id: comment.id
            )
          )
        end

        context "when the root commentable has been deleted" do
          before do
            comment.root_commentable.destroy!
            comment.reload
          end

          it { is_expected.to be_nil }
        end
      end

      describe "#users_to_notify_on_comment_created" do
        let(:user) { create(:user, organization: comment.organization) }

        it "includes the comment author" do
          expect(comment.users_to_notify_on_comment_created)
            .to include(author)
        end

        it "includes the values from its commentable" do
          allow(comment.commentable)
            .to receive(:users_to_notify_on_comment_created)
            .and_return(Decidim::User.where(id: user.id))

          expect(comment.users_to_notify_on_comment_created)
            .to include(user)
        end
      end

      describe "#formatted_body" do
        let(:comment) { create(:comment, commentable:, author:, body:) }
        let(:body) { "<b>bold text</b> %lorem% <a href='https://example.com'>link</a>" }

        before do
          allow(Decidim).to receive(:content_processors).and_return([:dummy_foo])
        end

        it "sanitizes user input" do
          expect(comment).to receive(:sanitize_content_for_comment)
          comment.formatted_body
        end

        it "process the body after it is sanitized" do
          expect(Decidim::ContentProcessor).to receive(:render).with("<p>bold text %lorem% link</p>", "div")
          comment.formatted_body
        end

        it "returns the body sanitized and processed" do
          expect(comment.formatted_body).to eq("<div><p>bold text <em>neque dicta enim quasi</em> link</p></div>")
        end

        describe "when the body contains multiline quotes" do
          let(:body) { "> quote first line\n> quote second line\n\nanswer" }
          let(:result) { "<div><blockquote class=\"comment__quote\"><p>quote first line\n<br />quote second line</p></blockquote><p>answer</p></div>" }

          it "parses quotes and renders them as blockquotes" do
            expect(comment.formatted_body).to eq(result)
          end
        end

        describe "when the body contains HTML" do
          let(:body) { %(<a target="alert(1)" href="javascript:alert(document.location)">XSS via target in a tag</a>) }
          let(:result) { "<div><p>XSS via target in a tag</p></div>" }

          it "parses the HTML and renders them only with accepted tags" do
            expect(comment.formatted_body).to eq(result)
          end
        end

        describe "when the body contains quotes with paragraphs" do
          let(:body) { "> quote first paragraph\n>\n> quote second paragraph\n\nanswer" }
          let(:result) { "<div><blockquote class=\"comment__quote\">\n<br /><p>quote first paragraph</p>\n<br /><p>quote second paragraph</p>\n<br /></blockquote><p>answer</p></div>" }

          it "parses quotes and renders them as blockquotes" do
            expect(comment.formatted_body).to eq(result)
          end
        end

        describe "when the body contains urls" do
          before { allow(Decidim).to receive(:content_processors).and_return([:link]) }

          let(:body) do
            %(Content with <a href="http://urls.net" onmouseover="alert('hello')">URLs</a> of anchor type and text urls like https://decidim.org. And a malicious <a href="javascript:document.cookies">click me</a>)
          end
          let(:result) do
            %(<div><p>Content with URLs of anchor type and text urls like <a href="https://decidim.org" target="_blank" rel="nofollow noopener noreferrer ugc">https://decidim.org</a>. And a malicious click me</p></div>)
          end

          it "converts all URLs to links and strips attributes in anchors" do
            expect(comment.formatted_body).to eq(result)
          end
        end
      end

      describe "#comment_threads count" do
        let!(:parent) { create(:comment, commentable:) }
        let!(:comments) { create_list(:comment, 3, commentable: parent, root_commentable: commentable) }

        it "return 3" do
          expect(parent.comment_threads.count).to eq 3
        end

        it "still returns 3 when a comment has been moderated" do
          Decidim::Moderation.create!(reportable: comments.last, participatory_space: comments.last.participatory_space, hidden_at: 1.day.ago)

          expect(parent.comment_threads.count).to eq 3
        end

        describe "#body_length" do
          context "when no default comments length specified" do
            let!(:body) { { en: ::Faker::Lorem.sentence(word_count: 1000) } }

            it "is invalid" do
              comment.body = body
              expect(subject).to be_invalid
              expect(subject.errors[:body]).to eq ["is too long (maximum is 1000 characters)"]
            end
          end

          context "when organization has a default comments length params" do
            let!(:body) { { en: ::Faker::Lorem.sentence(word_count: 1600) } }
            let(:organization) { create(:organization, comments_max_length: 1500) }
            let(:component) { create(:component, organization:, manifest_name: "dummy") }
            let!(:commentable) { create(:dummy_resource, component:) }

            it "is invalid" do
              comment.body = body
              expect(subject).to be_invalid
              expect(subject.errors[:body]).to eq ["is too long (maximum is 1500 characters)"]
            end

            context "when component has a default comments length params" do
              let!(:body) { { en: ::Faker::Lorem.sentence(word_count: 2500) } }

              it "is invalid" do
                component.update!(settings: { comments_max_length: 2000 })
                comment.body = body
                expect(subject).to be_invalid
                expect(subject.errors[:body]).to eq ["is too long (maximum is 2000 characters)"]
              end
            end
          end
        end
      end

      describe "#user_commentators_ids_in" do
        context "when passing a non-commentable resource" do
          it "returns the authors of the resources' comments" do
            ids = Decidim::Comments::Comment.user_commentators_ids_in([commentable.component.participatory_space])
            expect(ids).to be_empty
          end
        end

        context "when commenters belong to the given resources" do
          it "returns the authors of the resources' comments" do
            ids = Decidim::Comments::Comment.user_commentators_ids_in(Decidim::Dev::DummyResource.where(component: commentable.component))
            expect(ids).to contain_exactly(author.id)
          end
        end

        context "when commenters do not belong to the given resources" do
          let(:other_component) { create(:dummy_component) }
          let!(:other_commentable) { create(:dummy_resource, component: other_component) }

          it "does not return them" do
            ids = Decidim::Comments::Comment.user_commentators_ids_in(Decidim::Dev::DummyResource.where(component: commentable.component))
            expect(ids).to contain_exactly(author.id)
          end
        end
      end

      describe "#extra_actions_for" do
        it "returns blank" do
          expect(comment.extra_actions_for(author)).to eq([])
        end

        context "when the root commentable provides actions" do
          let(:actions) { "Some actions" }

          before do
            allow(commentable).to receive(:actions_for_comment).with(comment, author).and_return(actions)
          end

          it "returns the actions" do
            expect(comment.extra_actions_for(author)).to eq(actions)
          end
        end
      end
    end
  end
end
