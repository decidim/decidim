# frozen_string_literal: true

module Decidim
  class HideAllCreatedByAuthorJob < ApplicationJob
    queue_as :user_report

    def perform(resource:, extra: {})
      return unless extra.fetch(:hide, false)

      @author = resource.reload

      base_query.find_each do |content|
        hide_content(content, extra[:event_author], extra[:justification])
      end
    end

    protected

    attr_reader :author

    private

    def hide_content(content, current_user, justification)
      tool = Decidim::ModerationTools.new(content, current_user)
      tool.update_reported_content!
      tool.create_report!(reason: "hidden_during_block", details: justification)
      tool.update_report_count!
      tool.hide!
    end
  end
end
