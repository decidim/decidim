# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to create a new category in the
    # system.
    class CreateCategory < Decidim::Commands::CreateResource
      fetch_form_attributes :name, :weight, :parent_id

      # Public: Initializes the command.
      #
      # form - A form object with the params.
      # participatory_space - The participatory space that will hold the
      #   category
      def initialize(form, participatory_space)
        super(form)
        @participatory_space = participatory_space
      end

      protected

      attr_reader :participatory_space

      def resource_class = Decidim::Category

      def attributes = super.merge({ participatory_space: })
    end
  end
end
