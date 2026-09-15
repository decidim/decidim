# frozen_string_literal: true

module Decidim
  module Budgets
    module Pabulib
      # Creates the PB voting export in Pabulib format (.pb) for a participatory
      # budgeting budget. Note that the Pabulib format currently supports only a
      # single budget at a time which is why this only exports a single budget
      # at a time.
      class Writer
        # Initializes the writer.
        #
        # @param io [IO] The IO stream to write the data to
        # @param metadata [Decidim::Budgets::Pabulib::Metadata] The pabulib
        #   metadata object for the data
        def initialize(io, metadata)
          @io = io
          @metadata = metadata
        end

        # Writes the metadata part of the pabulib export to the IO.
        #
        # @return [nil]
        def write_metadata
          raise InvalidMetadataError, "Description not defined." if metadata.description.blank?

          write("META")
          write(key: "value")
          write(description: metadata.description)
          write_attributes(metadata, :country, :unit, :district, :subunit, :instance)
          write(num_projects: metadata.num_projects)
          write(num_votes: metadata.num_votes)
          write(budget: metadata.budget)
          write(vote_type: metadata.vote_type)
          write(rule: metadata.rule)

          if metadata.date_begin && metadata.date_end
            write(date_begin: metadata.date_begin.strftime("%d.%m.%Y"))
            write(date_end: metadata.date_end.strftime("%d.%m.%Y"))
          end

          write_attributes(metadata, :min_length, :max_length)
          write_type_attributes

          nil
        end

        # Writes the projects part of the pabulib export to the IO.
        #
        # @return [nil]
        def write_projects(data, &)
          write_data("PROJECTS", data, &)
        end

        # Writes the votes part of the pabulib export to the IO.
        #
        # @return [nil]
        def write_votes(data, &)
          write_data("VOTES", data, &)
        end

        private

        attr_reader :io, :metadata

        # Writes the given string (if any) and the provided keyword arguments
        # as CSV key-value pairs separated with a semicolon (;). Adds a new line
        # to the end of the string.
        #
        # @example Writes "string\n"
        #   writer.write("string")
        # @example Writes "foo;bar;baz;biz\n"
        #   writer.write(foo: "bar", bar: "biz")
        # @example Writes "a\nb;c\n"
        #   writer.write("a", b: "c")
        #
        # @param str [String, nil] Either a string or nil, nil or an empty
        #   string does not write anything
        # @param kwargs [Hash] Key-value pairs to write as CSV columns, each
        #   key-value is separated with a semicolon (;) and each pair is
        #   separated with a semicolon (;)
        # @return [Integer] The amount of bytes written
        def write(str = nil, **kwargs)
          io.write "#{str}\n" if str.present?
          return unless kwargs.any?

          write_row(kwargs.flat_map { |key, val| [key, val] })
        end

        # Writes a CSV row to the IO where columns are separated with a
        # semicolon (;).
        #
        # @param values [Array<String>] The column values to write
        # @return [Integer] The amount of bytes written
        def write_row(values)
          io.write CSV.generate_line(values, col_sep: ";")
        end

        # Writes the correct attributes from the metadata for each vote type.
        #
        # @raise [InvalidMetadataError] If the vote type is unknown
        # @return [nil]
        def write_type_attributes
          case metadata.vote_type
          when "approval"
            write_attributes(metadata, :min_sum_cost, :max_sum_cost)
          when "ordinal"
            write_attributes(metadata, :scoring_fn)
          when "cumulative"
            write_attributes(metadata, :min_points, :max_points, :min_sum_points, :max_sum_points)
          when "scoring"
            write_attributes(metadata, :min_points, :max_points, :default_score)
          else
            raise InvalidMetadataError, "Unknown vote_type: #{metadata.vote_type}"
          end
        end

        # Writes the attributes from the given source object.
        #
        # @example Writes "foo;foo_value\nbar;bar_value"
        #   Example = Struct.new(:foo, :bar)
        #   object = Example.new(foo: "foo_value", bar: "bar_value")
        #   writer.write_attributes(object, :foo, :bar)
        #
        # @param source [Object] The source object that publicly responds to
        #   the given attribute accessors
        # @param attrs [Array<Symbol>] The attribute accessor names as symbols
        #   that the given object publicly responds to
        # @return [nil]
        def write_attributes(source, *attrs)
          attrs.each do |key|
            val = source.public_send(key)
            write_row([key, val]) if val.present?
          end

          nil
        end

        # Writes the data section for the given data.
        #
        # @param section [String] The pabulib data section identifier
        # @param data [Array<Object>] The array of data objects to be converted
        #   and written
        # @yield [item] The data object to be converted to a formalized data
        #   struct object, the block should return the struct object
        # @yieldparam [Object] The data object to be converted
        # @yieldreturn [Decidim::Budgets::Pabulib::Project, Decidim::Budgets::Pabulib::Project]
        #   The formalized data struct object for pabulib
        # @return [nil]
        def write_data(section, data)
          return if data.empty?

          write(section)
          data.each_with_index do |item, idx|
            struct = yield item
            write_row(struct.members) if idx.zero?
            write_row(struct.members.map { |key| struct.public_send(key) })
          end

          nil
        end

        class Error < StandardError; end

        class InvalidMetadataError < Error; end
      end
    end
  end
end
