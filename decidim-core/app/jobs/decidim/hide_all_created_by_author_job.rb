# frozen_string_literal: true

module Decidim
  class HideAllCreatedByAuthorJob < ApplicationJob
    queue_as :user_report

    def perform(author:, justification:, current_user:)
      @author = author.reload
      @justification = justification

      base_query.find_each do |content|
        hide_content(content, current_user)
      end
    end

    protected

    def user_params
      {
        reason: "hidden_during_block",
        details: @justification
      }
    end

    private

    def hide_content(content, current_user)
      tool = Decidim::ModerationTools.new(content, current_user)
      tool.update_reported_content!
      tool.create_report!(user_params)
      tool.update_report_count!
      tool.hide!
    end
  end
end
