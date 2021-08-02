# frozen_string_literal: true

module Decidim
  module ContentParsers
    # A parser that searches for inline images in an html content and
    # replaces them with EditorImage attachments. Note that rewrite method may
    # create EditorImage instances
    #
    # @see BaseParser Examples of how to use a content parser
    class InlineImagesParser < BaseParser
      AVAILABLE_ATTRIBUTES = {
        "Decidim::Accountability::Result" => %w(description),
        "Decidim::Proposals::Proposal" => %w(body answer cost_report execution_period),
        "Decidim::Votings::Voting" => %w(description),
        "Decidim::Elections::Question" => %w(description),
        "Decidim::Elections::Answer" => %w(description),
        "Decidim::Elections::Election" => %w(description),
        "Decidim::Initiative" => %w(description answer),
        "Decidim::InitiativesType" => %w(description extra_fields_legal_information),
        "Decidim::Assembly" => %w(short_description description purpose_of_action composition internal_organisation announcement closing_date_reason special_features),
        "Decidim::Forms::Questionnaire" => %w(description tos),
        "Decidim::Forms::Question" => %w(description),
        "Decidim::Organization" => %w(welcome_notification_body admin_terms_of_use_body description highlighted_content_banner_short_description id_documents_explanation_text),
        "Decidim::StaticPage" => %w(content),
        "Decidim::ContextualHelpSection" => %w(content),
        "Decidim::Category" => %w(description),
        "Decidim::Blogs::Post" => %w(body),
        "Decidim::Pages::Page" => %w(body),
        "Decidim::Sortitions::Sortition" => %w(additional_info witnesses cancel_reason),
        "Decidim::Consultations::Question" => %w(title question_context what_is_decided instructions),
        "Decidim::Consultation" => %w(description),
        "Decidim::Debates::Debate" => %w(description instructions information_updates conclusions),
        "Decidim::Budgets::Budget" => %w(description),
        "Decidim::Budgets::Project" => %w(description),
        "Decidim::ConferenceSpeaker" => %w(short_bio),
        "Decidim::Conferences::RegistrationType" => %w(description),
        "Decidim::Conference" => %w(short_description description objectives registration_terms),
        "Decidim::ParticipatoryProcessGroup" => %w(description),
        "Decidim::ParticipatoryProcess" => %w(short_description description announcement),
        "Decidim::ParticipatoryProcessStep" => %w(description),
        "Decidim::Meetings::AgendaItem" => %w(description),
        "Decidim::Meetings::Meeting" => %w(registration_terms description registration_email_custom_content closing_report)
      }.each_with_object({}) do |(main_model, attributes), hash|
        hash[main_model.constantize] = attributes
      rescue NameError
        hash
      end.freeze

      # @return [String] the content with the inline images replaced.
      def rewrite
        return content unless inline_images?

        replace_inline_images
        parsed_content.to_html
      end

      def inline_images?
        parsed_content.search(:img).find do |image|
          image.attr(:src).start_with?(%r{data:image/[a-z]{3,4};base64,})
        end
      end

      private

      def parsed_content
        @parsed_content ||= Nokogiri::HTML(content)
      end

      def replace_inline_images
        parsed_content.search(:img).each do |image|
          next unless image.attr(:src).start_with?(%r{data:image/[a-z]{3,4};base64,})

          file = base64_tempfile(image.attr(:src))
          editor_image = EditorImage.create!(
            decidim_author_id: context[:user]&.id,
            organization: context[:user].organization,
            file: file
          )

          image.set_attribute(:src, editor_image.attached_uploader(:file).path)
        end
      end

      def base64_tempfile(base64_data, filename = nil)
        return base64_data unless base64_data.is_a? String

        start_regex = %r{data:image/[a-z]{3,4};base64,}
        filename ||= SecureRandom.hex

        regex_result = start_regex.match(base64_data)

        return unless base64_data && regex_result

        start = regex_result.to_s
        tempfile = Tempfile.new(filename)
        tempfile.binmode
        tempfile.write(Base64.decode64(base64_data[start.length..-1]))
        ActionDispatch::Http::UploadedFile.new(
          tempfile: tempfile,
          filename: filename,
          original_filename: filename
        )
      end
    end
  end
end
