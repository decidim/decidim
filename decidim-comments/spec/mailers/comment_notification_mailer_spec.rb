# -*- coding: utf-8 -*-
require "spec_helper"

module Decidim
  module Comments
    describe CommentNotificationMailer, type: :mailer do
      let(:commentable) { create(:dummy_resource) }
      let(:comment) { create(:comment, commentable: commentable) }

      describe "comment_created" do
        let(:mail) { described_class.comment_created(user, comment, commentable) }

        let(:subject) { "Tens un nou comentari" }
        let(:default_subject) { "You have a new comment" }

        let(:body) { "Hi ha un comentari nou de" }
        let(:default_body) { "There is a new comment" }

        include_examples "localised email"
      end
    end
  end
end
