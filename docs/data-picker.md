# Data Picker

Simple HTML `select`s are not usable enough for the big collections of data Decidim has. We tried using `select2`, but we found problems with its usage and responsiveness, so we moved to a custom data picker. Also, there are many kinds of data that can be selected and many better usable ways to select this data than the simple select provided by html.

Current Decidim's selector is inspired on [this](https://medium.com/@mibosc/responsive-design-why-and-how-we-ditched-the-good-old-select-element-bc190d62eff5) article.

Data Picker is a selector thought to be reusable in many contexts and kinds of data. The idea behind it is a reusable widget that opens a popup where the user will perform a given selection and, on finish, this selection is returned to the source widget in the main page. The popup is accompained by a semitransparent layer behind it to blur the background and keep the user concentrated in the current action, the selection.

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

Anchors in the selector can have the following attributes:
data-close: this anchor will be ignored
href: the url to be used for choosing
picker-choose: when 'undefined' will load the given href url. Otherwise a choose action in the component is invoked with params: `url: href, value: picker-value, text: picker-text`.
picker-value: the selected value
picker-text (optional): The text to be shown in the picker button.

### Returning the selection to the widget

To return the selection to the widget in the main page use javascript to set the data-picker-value in the #proposal-picker-choose button.
