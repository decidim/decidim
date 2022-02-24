# frozen_string_literal: true

module Decidim
  module Pages
    # Command that gets called whenever a component's page has to be duplicated.
    # It's need a context with the old component that
    # is going to be duplicated on the new one
    class CopyPage < Decidim::Command
      def initialize(context)
        @context = context
      end

      def call
        Decidim::Pages::Page.transaction do
          pages = Decidim::Pages::Page.where(component: @context[:old_component])
          pages.each do |page|
            Decidim::Pages::Page.create!(component: @context[:new_component], body: page.body)
          end
        end
        broadcast(:ok)
      rescue ActiveRecord::RecordInvalid
        broadcast(:invalid)
      end
    end
  end
end
