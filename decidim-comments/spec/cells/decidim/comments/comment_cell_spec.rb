# frozen_string_literal: true

require "spec_helper"

module Decidim::Comments
  describe CommentCell, type: :cell do
    controller Decidim::Comments::CommentsController

    subject { my_cell.call }

    let(:my_cell) { cell("decidim/comments/comment", comment) }
    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, organization:) }
    let(:assembly) { create(:assembly, organization:) }
    let(:component) { create(:component, participatory_space: participatory_process) }
    let(:commentable) { create(:dummy_resource, component:) }
    let(:comment) { create(:comment, commentable:) }
    let(:created_at) { Time.current }

    context "when rendering" do
      it "renders the card" do
        expect(subject).to have_css("#comment_#{comment.id}")
        # An empty replies element is needed when dynamically adding replies
        expect(subject).to have_css("#comment-#{comment.id}-replies", text: "")
        expect(subject).to have_css(".comment__content")
        expect(subject).to have_css("button[data-dialog-open='loginModal'][title='#{I18n.t("decidim.components.comment.report.action")}']")
        expect(subject).to have_css("a[href='/processes/#{participatory_process.slug}/f/#{component.id}/dummy_resources/#{commentable.id}?commentId=#{comment.id}#comment_#{comment.id}']")
        expect(subject).to have_content(comment.body.values.first)
        expect(subject).to have_content(created_at.strftime("%d/%m/%Y"))
        expect(subject).to have_content(comment.author.name)

        expect(subject).to have_no_css(".add-comment")
        expect(subject).to have_no_css(".comment-reply")
        expect(subject).to have_no_css("#flagModalComment#{comment.id}")
        expect(subject).to have_no_css(".label.alignment")
      end

      context "when deleted" do
        let(:comment) { create(:comment, :deleted, commentable:) }

        it "renders the card with a deletion message and replies" do
          expect(subject).to have_css("#comment_#{comment.id}")
          expect(subject).to have_css(".comment__deleted")
          expect(subject).to have_no_css("button[data-dialog-open='loginModal'][title='#{I18n.t("decidim.components.comment.report.action")}']")
          expect(subject).to have_no_css("a[href='/processes/#{participatory_process.slug}/f/#{component.id}/dummy_resources/#{commentable.id}?commentId=#{comment.id}#comment_#{comment.id}']")
          expect(subject).to have_no_content(comment.body.values.first)
          expect(subject).to have_no_content("less than a minute")
          expect(subject).to have_content(I18n.l(comment.deleted_at, format: :decidim_short))
          expect(subject).to have_no_content(comment.author.name)

          expect(subject).to have_no_css(".add-comment")
          expect(subject).to have_no_css(".comment-reply")
          expect(subject).to have_no_css("#flagModalComment#{comment.id}")
        end
      end

      context "when moderated" do
        let(:comment) { create(:comment, commentable:, created_at: 1.day.ago) }
        let!(:moderation) { create(:moderation, hidden_at: 6.hours.ago, reportable: comment) }

        it "renders the card with a moderation message and replies" do
          expect(subject).to have_css("#comment_#{comment.id}")
          expect(subject).to have_css(".comment__moderated")
          expect(subject).to have_no_css("button[data-dialog-open='loginModal'][title='#{I18n.t("decidim.components.comment.report.action")}']")
          expect(subject).to have_no_css("a[href='/processes/#{participatory_process.slug}/f/#{component.id}/dummy_resources/#{commentable.id}?commentId=#{comment.id}#comment_#{comment.id}']")
          expect(subject).to have_no_content(comment.body.values.first)
          expect(subject).to have_no_content("less than a minute")
          expect(subject).to have_content(I18n.l(moderation.hidden_at, format: :decidim_short))
          expect(subject).to have_no_content(comment.author.name)

          expect(subject).to have_no_css(".add-comment")
          expect(subject).to have_no_css(".comment-reply")
          expect(subject).to have_no_css("#flagModalComment#{comment.id}")
        end
      end

      context "when edited" do
        before do
          allow(comment).to receive(:edited?).and_return(true)
        end

        it "renders the card with an Edited message" do
          expect(subject).to have_css("#comment_#{comment.id}")
          expect(subject).to have_css("#comment-#{comment.id}-replies", text: "")
          expect(subject).to have_css(".comment__content")
          expect(subject).to have_css("button[data-dialog-open='loginModal'][title='#{I18n.t("decidim.components.comment.report.action")}']")
          expect(subject).to have_css("a[href='/processes/#{participatory_process.slug}/f/#{component.id}/dummy_resources/#{commentable.id}?commentId=#{comment.id}#comment_#{comment.id}']")
          expect(subject).to have_content("Edited")
          expect(subject).to have_content(comment.body.values.first)
          expect(subject).to have_content(created_at.strftime("%d/%m/%Y"))
          expect(subject).to have_content(comment.author.name)

          expect(subject).to have_no_css(".add-comment")
          expect(subject).to have_no_css(".comment-reply")
          expect(subject).to have_no_css(".label.alignment")
        end
      end

      context "with votes" do
        let(:comment) { create(:comment, commentable:) }

        before do
          allow(commentable).to receive(:comments_have_votes?).and_return(true)

          create_list(:comment_vote, 4, :up_vote, comment:)
          create_list(:comment_vote, 2, :down_vote, comment:)
        end

        it "renders the votes buttons" do
          expect(subject).to have_css(".comment__votes .js-comment__votes--up[data-dialog-open='loginModal']")
          expect(subject).to have_css(".comment__votes .js-comment__votes--down[data-dialog-open='loginModal']")
          expect(subject).to have_css(".js-comment__votes--up span", text: 4)
          expect(subject).to have_css(".js-comment__votes--down span", text: 2)
        end
      end

      context "with alignment" do
        context "when positive alignment" do
          let(:comment) { create(:comment, commentable:) }

          before do
            comment.update!(alignment: 1)
          end

          it "renders the correct alignment badge" do
            expect(subject).to have_css(".label.alignment.success", text: "In favor")
          end
        end

        context "when negative alignment" do
          let(:comment) { create(:comment, commentable:) }

          before do
            comment.update!(alignment: -1)
          end

          it "renders the correct alignment badge" do
            expect(subject).to have_css(".label.alignment.alert", text: "Against")
          end
        end
      end

      context "with replies" do
        let(:resource_locator) { Decidim::ResourceLocatorPresenter.new(commentable) }
        let!(:replies) { create_list(:comment, 10, commentable: comment) }

        before do
          allow(Decidim::ResourceLocatorPresenter).to receive(:new).and_return(resource_locator)
          allow(resource_locator).to receive(:path).and_return("/dummies")
        end

        it "renders the replies" do
          element = subject.find("#comment-#{comment.id}-replies")
          replies.each do |reply|
            expect(element).to have_css("#comment_#{reply.id}")
            expect(element).to have_content(reply.body.values.first)
          end
        end
      end

      context "when signed in" do
        let(:current_user) { create(:user, :confirmed, organization: component.organization) }

        before do
          allow(controller).to receive(:current_user).and_return(current_user)
        end

        it "renders the reply form" do
          expect(subject).to have_css(".add-comment")
          expect(subject).to have_css(".comment__actions button")
          expect(subject).to have_css("button[data-dialog-open='flagModalComment#{comment.id}']")
          expect(subject).to have_css("#flagModalComment#{comment.id}")
        end

        context "with votes" do
          before do
            allow(commentable).to receive(:comments_have_votes?).and_return(true)
          end

          it "renders the votes buttons" do
            expect(subject).to have_css("form.button_to[action='/comments/#{comment.id}/votes?weight=-1']")
            expect(subject).to have_css("form.button_to[action='/comments/#{comment.id}/votes?weight=1']")
          end

          context "with own vote" do
            before do
              create(:comment_vote, :up_vote, comment:, author: current_user)
            end

            it "renders the opposite vote button disabled" do
              expect(subject).to have_no_css(".js-comment__votes--up[disabled='disabled']")
              expect(subject).to have_css(".js-comment__votes--down[disabled='disabled']")
            end
          end
        end

        context "when comments are blocked" do
          before do
            allow(commentable).to receive(:user_allowed_to_comment?).and_return(false)
          end

          it "does not render the reply form" do
            expect(subject).to have_no_css(".add-comment")
          end

          context "and the user is an admin" do
            let(:current_user) { create(:user, :admin, :confirmed, organization: component.organization) }

            it "renders the reply form" do
              expect(subject).to have_css(".add-comment")
            end
          end

          context "and the user is a user manager" do
            let(:current_user) { create(:user, :user_manager, :confirmed, organization: component.organization) }

            it "renders the reply form" do
              expect(subject).to have_css(".add-comment")
            end
          end

          context "and the user is a valuator in the same participatory space" do
            let!(:valuator_role) { create(:participatory_process_user_role, user: current_user, participatory_process: component.participatory_space, role: :valuator) }

            it "renders the reply form" do
              expect(subject).to have_css(".add-comment")
            end
          end

          context "and the user is a valuator in another participatory process" do
            let!(:valuator_role) { create(:participatory_process_user_role, user: current_user, participatory_process: create(:participatory_process, organization: component.organization), role: :valuator) }

            it "does not render the reply form" do
              expect(subject).to have_no_css(".add-comment")
            end
          end

          context "and the user is a valuator in another participatory space" do
            let!(:component) { create(:component, participatory_space: assembly) }
            let!(:valuator_role) { create(:assembly_user_role, user: current_user, assembly: create(:assembly, organization: component.organization), role: :valuator) }

            it "does not render the reply form" do
              expect(subject).to have_no_css(".add-comment")
            end
          end
        end
      end
    end

    describe "#vote_button_to" do
      context "when commentable has permissions set for the vote_comment action" do
        let(:permissions) do
          {
            vote_comment: {
              authorization_handlers: {
                "dummy_authorization_handler" => { "options" => {} }
              }
            }
          }
        end

        let(:user) { create(:user, :confirmed, organization:) }

        before do
          organization.available_authorizations = ["dummy_authorization_handler"]
          organization.save!
          commentable.create_resource_permission(permissions:)
          allow(commentable).to receive(:comments_have_votes?).and_return(true)
          allow(subject).to receive(:current_user).and_return(user)
        end

        it "renders an action_authorized button" do
          expect(subject).to have_css("[data-onboarding-action=\"vote_comment\"]")
        end
      end

      context "when commentable has no permissions set for the vote_comment action" do
        it "renders a plain button" do
          expect(subject).to have_no_css("[data-onboarding-action=\"vote_comment\"]")
        end
      end
    end

    describe "#extra_actions" do
      let(:current_user) { create(:user, :confirmed, organization: component.organization) }
      let(:actions) do
        [{
          label: "Poke comment",
          url: "/poke"
        }]
      end

      before do
        allow(commentable).to receive(:actions_for_comment).with(comment, current_user).and_return(actions)
      end

      it "renders the extra actions" do
        expect(subject).to have_link("Poke comment", href: "/poke")
      end

      it "generates a cache hash with the action data" do
        hash = my_cell.send(:cache_hash)
        expect(hash).to include(actions.to_s)
      end
    end

    describe "#can_reply?" do
      before do
        allow(commentable).to receive(:user_allowed_to_comment?).and_return(true)
        allow(commentable).to receive(:accepts_new_comments?).and_return(true)
      end

      context "when depth is equal to MAX_DEPTH" do
        before do
          allow(controller).to receive(:user_signed_in?).and_return(true)
          allow(comment).to receive(:depth).and_return(Comment::MAX_DEPTH)
        end

        it "returns false when user is normal user" do
          expect(my_cell.send(:can_reply?)).to be false
        end

        it "returns false when user is admin user" do
          allow(my_cell).to receive(:user_has_any_role?).and_return(true)
          expect(my_cell.send(:can_reply?)).to be false
        end
      end

      context "when two columns layout is enabled" do
        before do
          allow(commentable).to receive(:two_columns_layout?).and_return(true)
        end

        it "returns false" do
          expect(my_cell.send(:can_reply?)).to be false
        end

        it "does not render the reply button" do
          expect(subject).to have_no_css("button[data-controls*='panel-']")
        end
      end

      context "when two columns layout is disabled" do
        before do
          allow(commentable).to receive(:two_columns_layout?).and_return(false)
        end

        it "returns true when user has the right role and comments are allowed" do
          allow(controller).to receive(:current_participatory_space).and_return(component.participatory_space)
          allow(my_cell).to receive(:user_has_any_role?).and_return(true)

          expect(my_cell.send(:can_reply?)).to be_truthy
        end

        it "renders the reply button when user has the right role and comments are allowed" do
          allow(controller).to receive(:current_participatory_space).and_return(component.participatory_space)
          allow(my_cell).to receive(:user_has_any_role?).and_return(true)

          expect(subject).to have_css("button[data-controls*='panel-']", text: I18n.t("decidim.components.comment.reply"))
        end

        it "returns true when user is signed in and allowed to comment" do
          allow(controller).to receive(:user_signed_in?).and_return(true)

          expect(my_cell.send(:can_reply?)).to be_truthy
        end

        it "renders the reply button when user is signed in and allowed to comment" do
          allow(controller).to receive(:user_signed_in?).and_return(true)

          expect(subject).to have_css("button[data-controls*='panel-']", text: I18n.t("decidim.components.comment.reply"))
        end

        it "returns false when comments are blocked" do
          allow(commentable).to receive(:accepts_new_comments?).and_return(false)

          expect(my_cell.send(:can_reply?)).to be false
        end

        it "does not render the reply button when comments are blocked" do
          allow(commentable).to receive(:accepts_new_comments?).and_return(false)

          expect(subject).to have_no_css("button[data-controls*='panel-']")
        end

        it "returns false when user is not allowed to comment" do
          allow(commentable).to receive(:user_allowed_to_comment?).and_return(false)

          expect(my_cell.send(:can_reply?)).to be false
        end

        it "does not render the reply button when user is not allowed to comment" do
          allow(commentable).to receive(:user_allowed_to_comment?).and_return(false)

          expect(subject).to have_no_css("button[data-controls*='panel-']")
        end

        it "returns false when user is not signed in" do
          allow(controller).to receive(:user_signed_in?).and_return(false)

          expect(my_cell.send(:can_reply?)).to be false
        end

        it "does not render the reply button when user is not signed in" do
          allow(controller).to receive(:user_signed_in?).and_return(false)

          expect(subject).to have_no_css("button[data-controls*='panel-']")
        end
      end
    end
  end
end
