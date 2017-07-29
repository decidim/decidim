# -*- coding: utf-8 -*-
# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe CommentNotificationMailer, type: :mailer do
      let(:organization) { create(:organization) }
      let(:participatory_process) { create(:participatory_process, organization: organization) }
      let(:feature) { create(:feature, featurable: participatory_process) }
      let(:commentable_author) { create(:user, organization: organization) }
      let(:commentable) { create(:dummy_resource, author: commentable_author, feature: feature) }
      let(:user) { create(:user, organization: organization) }
      let(:author) { create(:user, organization: organization) }
      let(:comment) { create(:comment, author: author, commentable: commentable) }
      let(:reply) { create(:comment, author: author, commentable: comment) }

      describe "comment_created" do
        let(:mail) { described_class.comment_created(user, comment, commentable) }

        let(:subject) { "Tens un nou comentari" }
        let(:default_subject) { "You have a new comment" }

        let(:body) { "Hi ha un nou comentari d" }
        let(:default_body) { "There is a new comment" }

        include_examples "user localised email"
      end

      describe "reply_created" do
        let(:mail) { described_class.reply_created(user, reply, comment, commentable) }

        let(:subject) { "Tens una nova resposta del teu comentari" }
        let(:default_subject) { "You have a new reply of your comment" }

        let(:body) { "Hi ha una nova resposta de" }
        let(:default_body) { "There is a new reply of your comment" }

        include_examples "user localised email"
      end
    end
  end
end
