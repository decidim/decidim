# frozen_string_literal: true

# This fixes a thread safety issue with the Webpacker compiler explained here:
# https://github.com/rails/webpacker/issues/2801
#
# The fix is partly from the issue and partly from this commit at Shakapacker:
# https://github.com/shakacode/shakapacker/commit/f2dc437ecd9914f394780d4c3150fc4a70d40f9d

require "webpacker/compiler"

module Decidim
  module Webpacker
    module ThreadSafeCompiler
      private

      def watched_files_digest
        warn "Webpacker::Compiler.watched_paths has been deprecated. Set additional_paths in webpacker.yml instead." unless watched_paths.empty?
        root_path = Pathname.new(File.expand_path(config.root_path))
        expanded_paths = [*default_watched_paths, *watched_paths].map do |path|
          root_path.join(path)
        end
        files = Dir[*expanded_paths].reject { |f| File.directory?(f) }
        file_ids = files.sort.map { |f| "#{File.basename(f)}/#{Digest::SHA1.file(f).hexdigest}" }
        Digest::SHA1.hexdigest(file_ids.join("/"))
      end
    end
  end
end

Webpacker::Compiler.prepend(Decidim::Webpacker::ThreadSafeCompiler)
