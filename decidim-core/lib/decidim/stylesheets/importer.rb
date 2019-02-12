# frozen_string_literal: false

module Decidim
  module Stylesheets
    class Importer < SassC::Importer
      attr_reader :colors, :env

      def initialize(options)
        @colors = options[:organization].colors
        @env = Rails.application.assets
      end

      def self.special_imports
        @special_imports ||= {}
      end

      def self.register_import(name, &blk)
        special_imports[name] = blk
      end

      register_import "organization_colors" do
        contents = ""
        colors.each do |name, hex|
          contents << "$#{name}: #{hex} !default;\n"
        end
        Import.new("organization_colors.scss", source: contents)
      end

      def imports(asset, _parent_path)
        if asset[-1] == "*"
          Dir["#{Compiler::ASSET_ROOT}/#{asset}.scss"].map do |path|
            Import.new(asset[0..-2] + File.basename(path, ".*"))
          end
        elsif callback = Importer.special_imports[asset]
          byebug
          instance_eval(&callback)
        else
          Import.new(env.find_asset(asset).filename)
        end
      end
    end
  end
end
