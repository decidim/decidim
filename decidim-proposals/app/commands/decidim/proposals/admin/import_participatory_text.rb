# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A command with all the business logic when an admin imports proposals from
      # a participatory text.
      class ImportParticipatoryText < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          @form.valid?
          return broadcast(:invalid) unless form.valid?

          save_participatory_text(form)
          parse_participatory_text_doc(form.document_to_s)

          broadcast(:ok)
        end

        private

        attr_reader :form

        def save_participatory_text(form)
          document = ParticipatoryText.find_or_initialize_by(component: form.current_component)
          document.update!(title: form.title, description: form.description)
        end

        def parse_participatory_text_doc(document)
          parser = Markdown2Proposals.new(form.current_component)
          parser.parse(document)
        end
      end
    end
  end
end
