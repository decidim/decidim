# frozen_string_literal: true

require "sassc"

module Decidim
  module Stylesheets
    autoload :Compiler, "decidim/stylesheets/compiler"
    autoload :Importer, "decidim/stylesheets/importer"

    def self.store(organization)
      styles = Compiler.compile_asset(organization)
      styles.each do |filename, content|
        file = Rails.root.join("public", "assets", filename)
        puts "Creating file #{file}"
        File.open(file, "w") do |f|
          f.write content
        end
      end
    end
  end
end
