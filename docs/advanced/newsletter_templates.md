# Newsletter templates

The newsletter templates allow the user to select a template amongst a set of of them, and use it as base to send newsletters. This allow for more customization on newsletter, tematic newsletters, etc.

Code-wise, they use the content blocks system internally, so [check the docs](https://github.com/decidim/decidim/blob/master/docs/advanced/content_blocks.md) for that section first.

## Adding a new template

You'll first need to register the template as a content block, but specifying `:newsletter_template` as its scope:

```ruby
Decidim.content_blocks.register(:newsletter_template, :my_template) do |content_block|
  content_block.cell "decidim/newsletter_templates/my_template"
  content_block.settings_form_cell = "decidim/newsletter_templates/my_template_settings_form"
  content_block.public_name_key "decidim.newsletter_templates.my_template.name"

  content_block.images = [
    {
      name: :main_image,
      uploader: "Decidim::NewsletterTemplateImageUploader",
      preview: -> { ActionController::Base.helpers.asset_path("decidim/placeholder.jpg") }
    }
  ]

  content_block.settings do |settings|
    settings.attribute(
      :body,
      type: :text,
      translated: true,
      preview: -> { ([I18n.t("decidim.newsletter_templates.my_template.body_preview")] * 100).join(" ") }
    )
  end
end
```

You'll need to add this into an initializer. Note that if you're adding this from a module, then you need to add it from the `engine.rb` file (check the docs for content blocks for more info).

This is the simplest template. It has a single attribute, in this case a translatable chunk of text. Let's go line by line.

Inside the block, first we define the path of the cell we'll use to render the email publicly. This cell will receive the `Decidim::ContentBlock` object, which will contain the attributes and any image we have (one in this example). In order to render cells, please note that emails have a very picky HTML syntax, so we suggest using some specialized tools to design the template, export the layout to HTML and render that through the cell. We suggest you make this cell inherit from `Decidim::NewsletterTemplates::BaseCell` for convenience.

Then we define the cell that will be used to render the form in the admin section. This form needs to show inputs for the attributes defined when registering the template. It will receive the `form` object to render the input fields. We suggest this cell to inherit from `Decidim::NewsletterTemplates::BaseSettingsFormCell`.

In the third line inside the block we define the I18n path to the public name of the template. This name will serve as identifier for the users who write the newsletters, so be sure to make it descriptive.

After that we define the images this newsletter supports. We give it a unique name, the class name of the uploader we'll use (the example one is the default one, but you might want to customize this value) and a way to preview this image. This preview image will only be used in the "Preview" page of the template, it's not a fallback. If you want a fallback, please implement it through a custom uploader (see `carrierwave`'s docs for that). There's no limit of the amount of images you add.

Finally, we define the attributes for the newsletter. In this case we define a body attribute, which is a translatable text. Whether this text require an editor or not will be defined by the settings cell. We also have a way to preview that attribute. There's no limit on the number of attributes you define.

## Interpolating the recipient name

Decidim accepts `%{name}` as a placeholder for the recipient name. If you want your template to use it, you'll need to call `parse_interpolations` in your public cell:

```ruby
class Decidim::NewsletterTemplates::MyTemplate < Decidim::ViewModel
  include Decidim::NewslettersHelper

  def body
    parse_interpolations(uninterpolated_body, recipient_user, newsletter.id)
  end
end
```

The newsletter subject is automatically interpolated.
