import "core-js/stable";
import "regenerator-runtime/runtime";
import $ from 'jquery';
import Quill from "quill"
import Rails from "@rails/ujs"
import "foundation-sites"

window.Quill = Quill;
window.Rails = Rails;
window.$ = window.jQuery = $;
