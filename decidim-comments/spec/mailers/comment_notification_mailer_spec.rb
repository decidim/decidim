# -*- coding: utf-8 -*-
require "spec_helper"

module Decidim
  module Comments
    describe CommentNotificationMailer, type: :mailer do
      let(:commentable) { create(:dummy_resource) }
      let(:comment) { create(:comment, commentable: commentable) }
      
      describe "comment_created" do
        let(:mail) { described_class.comment_created(user, comment, commentable) }

        include_examples "localised email"
      end
    end
  end
end
