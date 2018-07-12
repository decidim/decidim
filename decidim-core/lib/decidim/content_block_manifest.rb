# frozen_string_literal: true

module Decidim
  class ContentBlockManifest
    include ActiveModel::Model
    include Virtus.model

    attribute :name, Symbol
    attribute :cell_name, String, writer: :private
    attribute :image_names, Array[Symbol]
    attribute :options, Array[Hash]

    validates :name, :cell_name, presence: true
    validate :image_names_are_unique
    validate :option_names_are_unique

    def image(name)
      raise ImageNameCannotBeBlank if name.blank?

      image_names << name
    end

    def cell(cell_name)
      self.cell_name = cell_name
    end

    def option(name, type, metadata = {})
      raise OptionNameCannotBeBlank, "Option names cannot be blank" if name.blank?
      raise OptionTypeCannotBeBlank, "Option types cannot be blank" if type.blank?

      options << { name: name, type: type }.merge(metadata)
    end

    private

    def option_names_are_unique
      option_names = options.map { |option| option.fetch(:name) }
      errors.add(:options, :invalid) if option_names.count != option_names.uniq.count
    end

    def image_names_are_unique
      errors.add(:image_names, :invalid) if image_names.count != image_names.uniq.count
    end

    class ImageNameCannotBeBlank < StandardError; end
    class OptionNameCannotBeBlank < StandardError; end
    class OptionTypeCannotBeBlank < StandardError; end
  end
end
