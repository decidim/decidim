# frozen_string_literal: true

module Decidim
  module Budgets
    module Pabulib
      # Creates the PB voting export in Pabulib format (.pb) for a participatory
      # budgeting budget. Note that the Pabulib format currently supports only a
      # single budget at a time which is why this only exports a single budget
      # at a time.
      class Writer
        def initialize(io, metadata)
          @io = io
          @metadata = metadata
        end

        def write_metadata
          raise InvalidMetadataError, "Description not defined." if metadata.description.blank?

          write("META")
          write(key: "value")
          write(description: metadata.description)
          write_attributes(metadata, :country, :unit, :instance)
          write(num_projects: metadata.num_projects)
          write(num_votes: metadata.num_votes)
          write(budget: metadata.budget)
          write(rule: "greedy") # no other rules defined at this point
          write(vote_type: metadata.vote_type)

          write_attributes(metadata, :min_length, :max_length)
          write_type_attributes

          if metadata.date_begin && metadata.date_end
            write(date_begin: metadata.date_begin.strftime("%d.%m.%Y"))
            write(date_end: metadata.date_end.strftime("%d.%m.%Y"))
          end
        end

        def write_projects(data, &)
          write_data("PROJECTS", data, &)
        end

        def write_votes(data, &)
          write_data("VOTES", data, &)
        end

        private

        attr_reader :io, :metadata

        def write(str = nil, **kwargs)
          io.write "#{str}\n" if str.present?
          return unless kwargs.any?

          write_row(kwargs.flat_map { |key, val| [key, val] })
        end

        def write_row(values)
          io.write CSV.generate_line(values, col_sep: ";")
        end

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

        def write_attributes(source, *attrs)
          attrs.each do |key|
            val = source.public_send(key)
            write_row([key, val]) if val.present?
          end
        end

        def write_data(section, data)
          return if data.empty?

          write(section)
          data.each_with_index do |item, idx|
            struct = yield item
            write_row(struct.members) if idx.zero?
            write_row(struct.members.map { |key| struct.public_send(key) })
          end
        end

        class Error < StandardError; end

        class InvalidMetadataError < Error; end
      end
    end
  end
end
