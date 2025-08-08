# frozen_string_literal: true

module Decidim
  module Ai
    module SpamDetection
      module Importer
        class File
          def self.call(file, service)
            ext = ::File.extname(file)[1..-1]
            reader_class = Decidim::Admin::Import::Readers.search_by_file_extension(ext)

            reader_class.new(file).read_rows do |row|
              next unless [:spam, :ham].include?(row[0].to_sym)
              next if row[1].blank?

              service.train(row[0].to_sym, row[1])
            end
          end
        end
      end
    end
  end
end
