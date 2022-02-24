# frozen_string_literal: true

module Decidim
  # A command with all the business logic to create an editor image.
  class CreateEditorImage < Decidim::Command
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
      return broadcast(:invalid) if form.invalid?

      transaction do
        create_editor_image
      end

      broadcast(:ok, @editor_image)
    end

    private

    attr_reader :form

    def create_editor_image
      @editor_image = EditorImage.create!(
        decidim_author_id: form.current_user.id,
        organization: form.organization,
        file: form.file
      )
    end
  end
end
