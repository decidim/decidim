# frozen_string_literal: false

module Decidim
  module Stylesheets
    class Compiler
      ASSET_ROOT = Rails.root.join("app", "assets", "stylesheets")
      def self.compile_asset(organization)
        filename = "organization_#{organization.id}.scss"
        sass = "$primary: #000000; @import 'organization_colors'; @import 'decidim';"

        compile(sass, filename, organization)
      end

      def self.compile(stylesheet, filename, organization)
        compiled_file = "#{filename.sub(".scss", "")}.css"
        source_map_file = "#{compiled_file}.map"

        engine = SassC::Engine.new(stylesheet,
                                   importer: Importer,
                                   filename: filename,
                                   style: :compressed,
                                   source_map_file: source_map_file,
                                   source_map_contents: true,
                                   organization: organization,
                                   load_paths: [ASSET_ROOT])

        result = engine.render
        source_map = engine.source_map
        source_map.force_encoding("UTF-8")

        {
          compiled_file => result,
          source_map_file => source_map
        }
      end
    end
  end
end
