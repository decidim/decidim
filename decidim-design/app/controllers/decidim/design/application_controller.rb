# frozen_string_literal: true

module Decidim
  module Design
    class ApplicationController < ::DecidimController
      include NeedsOrganization

      helper_method :path_items

      def path_items(path)
        files = Dir.glob("#{gem_path}/app/views/decidim/design/#{path}/*.html.erb")

        files.map do |file|
          name = File.basename(file, ".html.erb")
          { name:, path: send("#{path.singularize}_path", name) }
        end
      end

      private

      def gem_path
        @gem_path ||= Bundler.load.specs.find { |spec| spec.name == "decidim-design" }.full_gem_path
      end
    end
  end
end
