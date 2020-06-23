# Data Picker

Simple HTML `select`s are not usable enough for the big collections of data Decidim has. We tried using `select2`, but we found problems with its usage and responsiveness, so we moved to a custom data picker. Also, there are many kinds of data that can be selected and many better usable ways to select this data than the simple select provided by html.

Current Decidim's selector is inspired on [this](https://medium.com/@mibosc/responsive-design-why-and-how-we-ditched-the-good-old-select-element-bc190d62eff5) article.

Data Picker is a selector thought to be reusable in many contexts and kinds of data. The idea behind it is a reusable widget that opens a popup where the user will perform a given selection and then return to the main page. The popup is accompained by a semitransparent layer behind it to blur the background and keep the user concentrated in the current action, the selection.

## Artifacts

Data Picker is composed by 2 visual artifacts, plus the javascript and one controller action for each selection type:

- **widget**: the first visual artifact is the widget that encapsulates the main Data Picker functionality. This widget manages the rendering of __the button__ that opens the selector and __the popup__. This button is managed via ujs (Unobtrusive JavaScript). The popup is empty and must be filled with a selection partial.
- **selection functionality** partial: There are many ways to select things (and many kinds of things to select). Thus, the selection functionality can be customized via a selection partial which will be rendered inside the widget's popup. This partial is supplied to the widget via ajax.
- **controller ajax action**: An ajax action will send the content of the popup in an html partial.

## How to

### Placing the Data Picker widget

The Data Picker widget structure is as follows:

```html
<div id="some-unique-id" class="data-picker <%= picker_options[:class]%>" data-picker-name="<%=picker_options[:name]%>">
  <div class="picker-values"><% @form.proposals.each do |proposal, params| %>
    <div><a href="<%= prompt_params[:url] %>" data-picker-value="<%=proposal%>"><%=proposal%></a></div>
  <% end %></div>
  <div class="picker-prompt"><a href="<%= prompt_params[:url] %>"><%= prompt_params[:text] %></a></div>
</div>
```

Placing the widget in a form requires two steps:

It is a good way to implement the widget to think that it is a component that takes parameters.

1. Prepare Data Picker parameters
  Data Picker takes two arguments the `picker_params` hash (to fill the main div) and the `prompt_params` hash (for the `picker-prompt` div).
  - `picker_params.id`: the html unique id of the widget instance, required by the JavaScript.
  - `picker_params.name`: the html name of the widget which will be sent by the form.
  - `picker_params.class`: one of `picker-multiple`, when user can select multiple data, or `picker-single`, when only one data is to be selected.

1. Html for the Data Picker widget

### Selector popup content

**Anchors** in the selector can have the following attributes:

- data-close: this anchor will be ignored and will close the picker
- href: the url to be used for choosing
- picker-choose: when not present the picker will navigate as a regular anchor. Otherwise a choose action in the component is invoked with params: `url: href, value: picker-value, text: picker-text`.
- picker-value: the selected value
- picker-text (optional): The text to be shown in the picker button.

This is an example of a link used to choose an element:

```html
  <a class="button" href="[picker path browsing this element]" data-picker-text="[text]" data-picker-value="[value]" data-picker-choose>[text]</a>
```

**Checkboxes** also can be used in the selector, to allow to select several values at once. In this case, the `href` attribute is replaced with `data-picker-url` and the `data-picker-value` attribute is replaced with the `value` built-in attribute.

This is an example of a checkbox that allow to choose an element without closing the picker:

```html
  <label><input type="checkbox" data-picker-url="[picker path browsing this element]" data-picker-text="[text]" value="[value]" data-picker-choose>[text]</label>
```

## Examples of use of the DataPicker

- Scopes picker: Allows to browse the tree of scopes and select one or several scopes.
  - [FormBuilder scopes picker field](../../decidim-core/lib/decidim/form_builder.rb): Basic method to render a scope picker for a form.
  - [FilterFormBuilder scopes picker field](../../decidim-core/lib/decidim/filter_form_builder.rb): Basic method to render a scope picker for a filter form.
  - [Scopes pickers helpers](../../decidim-core/app/helpers/decidim/scopes_helper.rb): Helpers to simplify the call to basic methods.
  - [Global scopes picker controller](../../decidim-core/app/controllers/decidim/scopes_controller.rb): Controller used to browse the scopes on a picker in any part of the application.
  - [Proposals' frontend form using a scopes picker](../../decidim-proposals/app/views/decidim/proposals/proposals/_edit_form_fields.html.erb): Use of a scope picker helper on a frontend page.
  - [Proposals' admin form using a scopes picker](../../decidim-proposals/app/views/decidim/proposals/admin/proposals/_form.html.erb): Use of a scope picker helper on an admin page.
  - [Meetings' multiple scopes picker for filtering](../../decidim-meetings/app/views/decidim/meetings/meetings/_filters.html.erb): Use of a multiple scopes picker on a filter form.
- Proposals picker: Allows to search and select multiple proposals to be referenced from other components.
  - [Proposals pickers helper](../../decidim-proposals/app/helpers/decidim/proposals/admin/proposals_picker_helper.rb): Helper to render a DataPicker for proposals selection.
  - [Proposals picker concern for admin pages](../../decidim-proposals/app/controllers/concerns/decidim/proposals/admin/picker.rb): You will need to add this concern to your controller, add a route for `proposals_picker` endpoint and create a view for it to show the proposals picker in your component context.
  - [Proposals picker cell](../../decidim-proposals/app/cells/decidim/proposals/proposals_picker_cell.rb): You can use this cell to reuse the logic in your picker view.
  - [Accountability's admin controller with a proposals picker](../../decidim-accountability/app/controllers/decidim/accountability/admin/results_controller.rb): It only needs to add the concern (and the endpoint to the routes).
  - [Accountability's admin view with a proposals picker](../../decidim-accountability/app/views/decidim/accountability/admin/results/proposals_picker.html.erb): It only needs to render the cell.