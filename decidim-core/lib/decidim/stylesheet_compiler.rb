# frozen_string_literal: true

module Decidim
  # This class parse sass styles to generate stylesheets for each organization
  class StylesheetCompiler < Decidim::ApplicationController
    attr_reader :env, :filename, :scss_file, :css_file

    def initialize(organization)
      @filename = "#{organization.id}-#{organization.name.parameterize}"
      @scss_file = File.new(scss_file_path, "w")
      @css_file = File.new(css_file_path, "w")
      @env = Rails.application.assets
    end

    def compile
      create_scss
      css_file.write generate_css
    ensure
      css_file.close
      scss_file.close
      File.delete(scss_file)
    end

    private

    def scss_file_path
      @scss_file_path ||= File.join(scss_tmpfile_path, "#{filename}.scss")
    end

    def scss_tmpfile_path
      @scss_tmpfile_path ||= Rails.root.join("app", "assets", "stylesheets", "generate_css")
      FileUtils.mkdir_p(@scss_tmpfile_path) unless File.exist?(@scss_tmpfile_path)
      @scss_tmpfile_path
    end

    def template_file_path
      @template_file_path ||= Rails.root.join("app", "assets", "stylesheets", "_organization.scss.erb")
    end

    def css_path
      @css_path ||= Rails.root.join("public", "styles")
      FileUtils.mkdir_p(@css_path) unless File.exist?(@css_path)
      @css_path
    end

    def css_file_path
      @css_file_path ||= Rails.root.join(css_path, "#{filename}.css")
    end

    def create_scss
      body = render_to_string(partial: "decidim/stylesheets/organization.scss", layout: false)
      byebug
      File.open(scss_file_path, "w") { |f| f.write(body) }
    end

    def generate_css
      Sass::Engine.new(asset_source,
                       syntax: :scss,
                       cache: false,
                       read_cache: false,
                       style: :compressed).render
    end

    def asset_source
      if env.find_asset(filename)
        env.find_asset(filename).source
      else
        uri = Sprockets::URIUtils.build_asset_uri(scss_file.path, type: "text/css")
        asset = Sprockets::UnloadedAsset.new(uri, env)
        env.load(asset.uri).source
      end
    end
  end
end
