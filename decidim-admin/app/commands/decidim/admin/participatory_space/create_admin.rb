# frozen_string_literal: true

module Decidim
  module Admin
    module ParticipatorySpace
      class CreateAdmin < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # participatory_space - The ParticipatoryProcess that will hold the
        #   user role
        def initialize(form, participatory_space)
          @form = form
          @current_user = form.current_user
          @participatory_space = participatory_space
        end

        private

        attr_reader :form, :participatory_space, :current_user, :user
      end
    end
  end
end
