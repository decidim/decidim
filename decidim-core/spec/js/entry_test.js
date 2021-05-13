/* eslint id-length: ["error", { "exceptions": ["$"] }] */

const $ = require("jquery");
window.$ = $;

import { configure } from "enzyme";
import Adapter from "enzyme-adapter-react-16";

configure({ adapter: new Adapter() });
