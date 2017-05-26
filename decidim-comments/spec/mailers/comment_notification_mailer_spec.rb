# -*- coding: utf-8 -*-
# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe CommentNotificationMailer, type: :mailer do
      let(:commentable) { create(:dummy_resource) }
      let(:comment) { create(:comment, commentable: commentable) }
      let(:reply) { create(:comment, commentable: comment) }

      describe "comment_created" do
        let(:mail) { described_class.comment_created(user, comment, commentable) }

        let(:subject) { "Tens un nou comentari" }
        let(:default_subject) { "You have a new comment" }

        let(:body) { "Hi ha un nou comentari d" }
        let(:default_body) { "There is a new comment" }

        include_examples "localised email"
      end

      describe "reply_created" do
        let(:mail) { described_class.reply_created(user, reply, comment, commentable) }

        let(:subject) { "Tens una nova resposta del teu comentari" }
        let(:default_subject) { "You have a new reply of your comment" }

        let(:body) { "Hi ha una nova resposta de" }
        let(:default_body) { "There is a new reply of your comment" }

        include_examples "localised email"
      end
    end
  end
end
