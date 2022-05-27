# frozen_string_literal: true

require "json"

module Decidim
  module Admin
    module Import
      module Readers
        # Imports any exported JSON file to local objects. It transforms the
        # import data using the creator into the final target objects.
        class JSON < Base
          MIME_TYPE = "application/json"

          def read_rows
            json_string = File.read(file)
            columns = []
            data = ::JSON.parse(json_string)
            data.each_with_index do |row, index|
              row = flat_hash(row)
              if index.zero?
                columns = row.keys
                yield columns.map(&:to_s), index
              end

              values = columns.map { |c| row[c] }
              last_present = values.rindex { |v| !v.nil? }
              if last_present
                yield values[0..last_present], index + 1
              else
                yield [], index + 1
              end
            end
          rescue ::JSON::ParserError
            raise Decidim::Admin::Import::InvalidFileError, "The provided JSON file is not valid"
          end

          # Returns a StringIO
          def example_file(data)
            columns = data.shift
            json_data = data.map do |row|
              deep_hash(
                columns.each_with_index.to_h { |col, ind| [col, row[ind]] }
              )
            end

            ::StringIO.new(::JSON.pretty_generate(json_data))
          end

          private

          # Converts e.g. structure as follows:
          # { title: { en: => "Foo", es: => "Bar" } }
          #
          # Into:
          # { "title/en": "Foo", "title/es": "Bar" }
          def flat_hash(data)
            {}.tap do |final|
              data.each do |key, value|
                if value.is_a?(Hash)
                  flat_hash(value).each do |subkey, subvalue|
                    final["#{key}/#{subkey}".to_sym] = subvalue
                  end
                else
                  final[key.to_sym] = value
                end
              end
            end
          end

          # Converts e.g. structure as follows:
          # { "title/en": "Foo", "title/es": "Bar" }
          #
          # Into:
          # { title: { en: "Foo", es: "Bar" } }
          def deep_hash(data)
            {}.tap do |final|
              data.each do |key, value|
                keyparts = key.to_s.split("/")
                current = final
                while (keypart = keyparts.shift&.to_sym)
                  if keyparts.any?
                    current[keypart] ||= {}
                    current = current[keypart]
                  else
                    current[keypart] = value
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
