# frozen_string_literal: true
module Decidim
  module Pages
    # Command that gets called whenever a feature's page has to be duplicated.
    # It's need a context with the old feature that
    # is going to be duplicated on the new one
    class CopyPage < Rectify::Command
      def initialize(context)
        @context = context
      end

      def call
        begin
          Decidim::Pages::Page.transaction do
            pages = Decidim::Pages::Page.where(feature: @context[:old_feature])
            pages.each do |page|
              Decidim::Pages::Page.create!(feature: @context[:new_feature], body: page.body)
            end
          end
          broadcast(:ok)
        rescue ActiveRecord::RecordInvalid
          broadcast(:invalid)
        end
      end
    end
  end
end
