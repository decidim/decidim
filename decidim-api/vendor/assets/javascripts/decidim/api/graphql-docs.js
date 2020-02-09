(function webpackUniversalModuleDefinition(root, factory) {
	if(typeof exports === 'object' && typeof module === 'object')
		module.exports = factory(require("react"));
	else if(typeof define === 'function' && define.amd)
		define(["react"], factory);
	else if(typeof exports === 'object')
		exports["GraphQLDocs"] = factory(require("react"));
	else
		root["GraphQLDocs"] = factory(root["React"]);
})(this, function(__WEBPACK_EXTERNAL_MODULE_1__) {
return /******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId])
/******/ 			return installedModules[moduleId].exports;
/******/
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			exports: {},
/******/ 			id: moduleId,
/******/ 			loaded: false
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.loaded = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ (function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	    value: true
	});
	exports.GraphQLDocs = undefined;
	
	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();
	
	var _react = __webpack_require__(1);
	
	var _react2 = _interopRequireDefault(_react);
	
	var _SchemaDocsView = __webpack_require__(2);
	
	var _model = __webpack_require__(29);
	
	var _introspectionQuery = __webpack_require__(65);
	
	var _introspectionQuery2 = _interopRequireDefault(_introspectionQuery);
	
	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
	
	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
	
	function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }
	
	function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }
	
	var GraphQLDocs = exports.GraphQLDocs = function (_React$Component) {
	    _inherits(GraphQLDocs, _React$Component);
	
	    function GraphQLDocs() {
	        _classCallCheck(this, GraphQLDocs);
	
	        return _possibleConstructorReturn(this, (GraphQLDocs.__proto__ || Object.getPrototypeOf(GraphQLDocs)).apply(this, arguments));
	    }
	
	    _createClass(GraphQLDocs, [{
	        key: 'componentWillMount',
	        value: function componentWillMount() {
	            var _this2 = this;
	
	            var promise = this.props.fetcher(_introspectionQuery2.default);
	
	            promise.then(function (json) {
	                console.log(new _model.Schema(json.data));
	                _this2.setState({
	                    schema: new _model.Schema(json.data)
	                });
	            });
	        }
	    }, {
	        key: 'render',
	        value: function render() {
	            if (this.state && this.state.schema) {
	                return _react2.default.createElement(_SchemaDocsView.SchemaDocsView, { schema: this.state.schema });
	            } else {
	                return _react2.default.createElement('div', null);
	            }
	        }
	    }]);
	
	    return GraphQLDocs;
	}(_react2.default.Component);

/***/ }),
/* 1 */
/***/ (function(module, exports) {

	module.exports = __WEBPACK_EXTERNAL_MODULE_1__;

/***/ }),
/* 2 */
/***/ (function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	    value: true
	});
	exports.SchemaDocsView = undefined;
	
	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();
	
	var _react = __webpack_require__(1);
	
	var _react2 = _interopRequireDefault(_react);
	
	var _reactTypeahead = __webpack_require__(3);
	
	var _model = __webpack_require__(29);
	
	var _schemaWalker = __webpack_require__(30);
	
	var _TypeDocsViews = __webpack_require__(31);
	
	var _SectionView = __webpack_require__(56);
	
	var _SectionView2 = _interopRequireDefault(_SectionView);
	
	var _SideNavSectionView = __webpack_require__(60);
	
	var _SideNavSectionView2 = _interopRequireDefault(_SideNavSectionView);
	
	var _SchemaDocsView = __webpack_require__(63);
	
	var StyleSheet = _interopRequireWildcard(_SchemaDocsView);
	
	function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }
	
	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
	
	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
	
	function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }
	
	function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }
	
	var SchemaDocsView = exports.SchemaDocsView = function (_React$Component) {
	    _inherits(SchemaDocsView, _React$Component);
	
	    function SchemaDocsView(props) {
	        _classCallCheck(this, SchemaDocsView);
	
	        var _this = _possibleConstructorReturn(this, (SchemaDocsView.__proto__ || Object.getPrototypeOf(SchemaDocsView)).call(this, props));
	
	        _this.handleSelect = _this.handleSelect.bind(_this);
	        return _this;
	    }
	
	    _createClass(SchemaDocsView, [{
	        key: 'handleSelect',
	        value: function handleSelect(name) {
	            location.hash = '#' + name;
	        }
	    }, {
	        key: 'render',
	        value: function render() {
	            var _this2 = this;
	
	            var types = (0, _schemaWalker.getReferencesInSchema)(this.props.schema).map(function (tn) {
	                return _this2.props.schema.types[tn];
	            });
	            var sections = {
	                schema: { name: 'Schema', items: [] },
	                objects: { name: 'Object Types', items: [] },
	                inputs: { name: 'Input Types', items: [] },
	                unions: { name: 'Unions', items: [] },
	                interfaces: { name: 'Interfaces', items: [] },
	                enums: { name: 'Enums', items: [] },
	                scalars: { name: 'Scalars', items: [] }
	            };
	            var options = [];
	
	            types.forEach(function (t) {
	                if (t instanceof _model.ObjectType) {
	                    var component = _react2.default.createElement(_TypeDocsViews.ObjectDocsView, {
	                        key: t.name,
	                        type: t,
	                        titleOverride: _this2.titleOverrideFor(t)
	                    });
	                    if (t === _this2.props.schema.getQueryType() || t === _this2.props.schema.getMutationType()) {
	                        sections.schema.items.push({ name: t.name, component: component });
	                        options.push(t.name);
	                    } else {
	                        sections.objects.items.push({ name: t.name, component: component });
	                        options.push(t.name);
	                    }
	                }
	                if (t instanceof _model.UnionType) {
	                    options.push(t.name);
	                    sections.unions.items.push({ name: t.name, component: _react2.default.createElement(_TypeDocsViews.UnionDocsView, {
	                            key: t.name,
	                            type: t
	                        }) });
	                }
	                if (t instanceof _model.InterfaceType) {
	                    options.push(t.name);
	                    sections.interfaces.items.push({ name: t.name, component: _react2.default.createElement(_TypeDocsViews.InterfaceDocsView, {
	                            key: t.name,
	                            type: t
	                        }) });
	                }
	                if (t instanceof _model.EnumType) {
	                    options.push(t.name);
	                    sections.enums.items.push({ name: t.name, component: _react2.default.createElement(_TypeDocsViews.EnumDocsView, {
	                            key: t.name,
	                            type: t
	                        }) });
	                }
	                if (t instanceof _model.InputObjectType) {
	                    options.push(t.name);
	                    sections.inputs.items.push({ name: t.name, component: _react2.default.createElement(_TypeDocsViews.InputObjectDocsView, {
	                            key: t.name,
	                            type: t
	                        }) });
	                }
	                if (t instanceof _model.ScalarType) {
	                    options.push(t.name);
	                    sections.scalars.items.push({ name: t.name, component: _react2.default.createElement(_TypeDocsViews.ScalarDocsView, {
	                            key: t.name,
	                            type: t
	                        }) });
	                }
	            });
	
	            Object.keys(sections).forEach(function (key) {
	                var section = sections[key];
	                section.items.sort(function (itemA, itemB) {
	                    if (itemA.name.toUpperCase() < itemB.name.toUpperCase()) {
	                        return -1;
	                    }
	                    if (itemA.name.toUpperCase() > itemB.name.toUpperCase()) {
	                        return 1;
	                    }
	                    return 0;
	                });
	            });
	
	            var customClasses = {
	                input: StyleSheet.selectInput,
	                results: StyleSheet.selectList,
	                listItem: StyleSheet.selectItem,
	                hover: StyleSheet.selectHover
	            };
	
	            return _react2.default.createElement(
	                'div',
	                { className: StyleSheet.wrapper },
	                _react2.default.createElement(
	                    'div',
	                    { className: StyleSheet.sidenav },
	                    _react2.default.createElement(_reactTypeahead.Typeahead, {
	                        options: options,
	                        maxVisible: 6,
	                        placeholder: 'Search types',
	                        customClasses: customClasses,
	                        onOptionSelected: this.handleSelect
	                    }),
	                    _react2.default.createElement('br', null),
	                    Object.keys(sections).map(function (key) {
	                        var section = sections[key];
	                        return section.items.length > 0 ? _react2.default.createElement(_SideNavSectionView2.default, { name: section.name, items: section.items }) : '';
	                    })
	                ),
	                _react2.default.createElement(
	                    'div',
	                    { className: StyleSheet.content },
	                    _react2.default.createElement(
	                        'div',
	                        { className: StyleSheet.container },
	                        Object.keys(sections).map(function (key) {
	                            var section = sections[key];
	                            return section.items.length > 0 ? _react2.default.createElement(_SectionView2.default, { name: section.name, items: section.items }) : '';
	                        })
	                    )
	                )
	            );
	        }
	    }, {
	        key: 'titleOverrideFor',
	        value: function titleOverrideFor(t) {
	            if (t === this.props.schema.getQueryType()) {
	                return 'Query';
	            }
	            if (t === this.props.schema.getMutationType()) {
	                return 'Mutations';
	            }
	
	            return null;
	        }
	    }]);
	
	    return SchemaDocsView;
	}(_react2.default.Component);

/***/ }),
/* 3 */
/***/ (function(module, exports, __webpack_require__) {

	var Typeahead = __webpack_require__(4);
	var Tokenizer = __webpack_require__(27);
	
	module.exports = {
	  Typeahead: Typeahead,
	  Tokenizer: Tokenizer
	};

/***/ }),
/* 4 */
/***/ (function(module, exports, __webpack_require__) {

	var _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; };
	
	var Accessor = __webpack_require__(5);
	var React = __webpack_require__(1);
	var TypeaheadSelector = __webpack_require__(6);
	var KeyEvent = __webpack_require__(25);
	var fuzzy = __webpack_require__(26);
	var classNames = __webpack_require__(8);
	var createReactClass = __webpack_require__(9);
	var PropTypes = __webpack_require__(17);
	
	/**
	 * A "typeahead", an auto-completing text input
	 *
	 * Renders an text input that shows options nearby that you can use the
	 * keyboard or mouse to select.  Requires CSS for MASSIVE DAMAGE.
	 */
	var Typeahead = createReactClass({
	  displayName: 'Typeahead',
	
	  propTypes: {
	    name: PropTypes.string,
	    customClasses: PropTypes.object,
	    maxVisible: PropTypes.number,
	    resultsTruncatedMessage: PropTypes.string,
	    options: PropTypes.array,
	    allowCustomValues: PropTypes.number,
	    initialValue: PropTypes.string,
	    value: PropTypes.string,
	    placeholder: PropTypes.string,
	    disabled: PropTypes.bool,
	    textarea: PropTypes.bool,
	    inputProps: PropTypes.object,
	    onOptionSelected: PropTypes.func,
	    onChange: PropTypes.func,
	    onKeyDown: PropTypes.func,
	    onKeyPress: PropTypes.func,
	    onKeyUp: PropTypes.func,
	    onFocus: PropTypes.func,
	    onBlur: PropTypes.func,
	    filterOption: PropTypes.oneOfType([PropTypes.string, PropTypes.func]),
	    searchOptions: PropTypes.func,
	    displayOption: PropTypes.oneOfType([PropTypes.string, PropTypes.func]),
	    inputDisplayOption: PropTypes.oneOfType([PropTypes.string, PropTypes.func]),
	    formInputOption: PropTypes.oneOfType([PropTypes.string, PropTypes.func]),
	    defaultClassNames: PropTypes.bool,
	    customListComponent: PropTypes.oneOfType([PropTypes.element, PropTypes.func]),
	    showOptionsWhenEmpty: PropTypes.bool
	  },
	
	  getDefaultProps: function () {
	    return {
	      options: [],
	      customClasses: {},
	      allowCustomValues: 0,
	      initialValue: "",
	      value: "",
	      placeholder: "",
	      disabled: false,
	      textarea: false,
	      inputProps: {},
	      onOptionSelected: function (option) {},
	      onChange: function (event) {},
	      onKeyDown: function (event) {},
	      onKeyPress: function (event) {},
	      onKeyUp: function (event) {},
	      onFocus: function (event) {},
	      onBlur: function (event) {},
	      filterOption: null,
	      searchOptions: null,
	      inputDisplayOption: null,
	      defaultClassNames: true,
	      customListComponent: TypeaheadSelector,
	      showOptionsWhenEmpty: false,
	      resultsTruncatedMessage: null
	    };
	  },
	
	  getInitialState: function () {
	    return {
	      // The options matching the entry value
	      searchResults: this.getOptionsForValue(this.props.initialValue, this.props.options),
	
	      // This should be called something else, "entryValue"
	      entryValue: this.props.value || this.props.initialValue,
	
	      // A valid typeahead value
	      selection: this.props.value,
	
	      // Index of the selection
	      selectionIndex: null,
	
	      // Keep track of the focus state of the input element, to determine
	      // whether to show options when empty (if showOptionsWhenEmpty is true)
	      isFocused: false,
	
	      // true when focused, false onOptionSelected
	      showResults: false
	    };
	  },
	
	  _shouldSkipSearch: function (input) {
	    var emptyValue = !input || input.trim().length == 0;
	
	    // this.state must be checked because it may not be defined yet if this function
	    // is called from within getInitialState
	    var isFocused = this.state && this.state.isFocused;
	    return !(this.props.showOptionsWhenEmpty && isFocused) && emptyValue;
	  },
	
	  getOptionsForValue: function (value, options) {
	    if (this._shouldSkipSearch(value)) {
	      return [];
	    }
	
	    var searchOptions = this._generateSearchFunction();
	    return searchOptions(value, options);
	  },
	
	  setEntryText: function (value) {
	    this.refs.entry.value = value;
	    this._onTextEntryUpdated();
	  },
	
	  focus: function () {
	    this.refs.entry.focus();
	  },
	
	  _hasCustomValue: function () {
	    if (this.props.allowCustomValues > 0 && this.state.entryValue.length >= this.props.allowCustomValues && this.state.searchResults.indexOf(this.state.entryValue) < 0) {
	      return true;
	    }
	    return false;
	  },
	
	  _getCustomValue: function () {
	    if (this._hasCustomValue()) {
	      return this.state.entryValue;
	    }
	    return null;
	  },
	
	  _renderIncrementalSearchResults: function () {
	    // Nothing has been entered into the textbox
	    if (this._shouldSkipSearch(this.state.entryValue)) {
	      return "";
	    }
	
	    // Something was just selected
	    if (this.state.selection) {
	      return "";
	    }
	
	    return React.createElement(this.props.customListComponent, {
	      ref: 'sel', options: this.props.maxVisible ? this.state.searchResults.slice(0, this.props.maxVisible) : this.state.searchResults,
	      areResultsTruncated: this.props.maxVisible && this.state.searchResults.length > this.props.maxVisible,
	      resultsTruncatedMessage: this.props.resultsTruncatedMessage,
	      onOptionSelected: this._onOptionSelected,
	      allowCustomValues: this.props.allowCustomValues,
	      customValue: this._getCustomValue(),
	      customClasses: this.props.customClasses,
	      selectionIndex: this.state.selectionIndex,
	      defaultClassNames: this.props.defaultClassNames,
	      displayOption: Accessor.generateOptionToStringFor(this.props.displayOption) });
	  },
	
	  getSelection: function () {
	    var index = this.state.selectionIndex;
	    if (this._hasCustomValue()) {
	      if (index === 0) {
	        return this.state.entryValue;
	      } else {
	        index--;
	      }
	    }
	    return this.state.searchResults[index];
	  },
	
	  _onOptionSelected: function (option, event) {
	    var nEntry = this.refs.entry;
	    nEntry.focus();
	
	    var displayOption = Accessor.generateOptionToStringFor(this.props.inputDisplayOption || this.props.displayOption);
	    var optionString = displayOption(option, 0);
	
	    var formInputOption = Accessor.generateOptionToStringFor(this.props.formInputOption || displayOption);
	    var formInputOptionString = formInputOption(option);
	
	    nEntry.value = optionString;
	    this.setState({ searchResults: this.getOptionsForValue(optionString, this.props.options),
	      selection: formInputOptionString,
	      entryValue: optionString,
	      showResults: false });
	    return this.props.onOptionSelected(option, event);
	  },
	
	  _onTextEntryUpdated: function () {
	    var value = this.refs.entry.value;
	    this.setState({ searchResults: this.getOptionsForValue(value, this.props.options),
	      selection: '',
	      entryValue: value });
	  },
	
	  _onEnter: function (event) {
	    var selection = this.getSelection();
	    if (!selection) {
	      return this.props.onKeyDown(event);
	    }
	    return this._onOptionSelected(selection, event);
	  },
	
	  _onEscape: function () {
	    this.setState({
	      selectionIndex: null
	    });
	  },
	
	  _onTab: function (event) {
	    var selection = this.getSelection();
	    var option = selection ? selection : this.state.searchResults.length > 0 ? this.state.searchResults[0] : null;
	
	    if (option === null && this._hasCustomValue()) {
	      option = this._getCustomValue();
	    }
	
	    if (option !== null) {
	      return this._onOptionSelected(option, event);
	    }
	  },
	
	  eventMap: function (event) {
	    var events = {};
	
	    events[KeyEvent.DOM_VK_UP] = this.navUp;
	    events[KeyEvent.DOM_VK_DOWN] = this.navDown;
	    events[KeyEvent.DOM_VK_RETURN] = events[KeyEvent.DOM_VK_ENTER] = this._onEnter;
	    events[KeyEvent.DOM_VK_ESCAPE] = this._onEscape;
	    events[KeyEvent.DOM_VK_TAB] = this._onTab;
	
	    return events;
	  },
	
	  _nav: function (delta) {
	    if (!this._hasHint()) {
	      return;
	    }
	    var newIndex = this.state.selectionIndex === null ? delta == 1 ? 0 : delta : this.state.selectionIndex + delta;
	    var length = this.props.maxVisible ? this.state.searchResults.slice(0, this.props.maxVisible).length : this.state.searchResults.length;
	    if (this._hasCustomValue()) {
	      length += 1;
	    }
	
	    if (newIndex < 0) {
	      newIndex += length;
	    } else if (newIndex >= length) {
	      newIndex -= length;
	    }
	
	    this.setState({ selectionIndex: newIndex });
	  },
	
	  navDown: function () {
	    this._nav(1);
	  },
	
	  navUp: function () {
	    this._nav(-1);
	  },
	
	  _onChange: function (event) {
	    if (this.props.onChange) {
	      this.props.onChange(event);
	    }
	
	    this._onTextEntryUpdated();
	  },
	
	  _onKeyDown: function (event) {
	    // If there are no visible elements, don't perform selector navigation.
	    // Just pass this up to the upstream onKeydown handler.
	    // Also skip if the user is pressing the shift key, since none of our handlers are looking for shift
	    if (!this._hasHint() || event.shiftKey) {
	      return this.props.onKeyDown(event);
	    }
	
	    var handler = this.eventMap()[event.keyCode];
	
	    if (handler) {
	      handler(event);
	    } else {
	      return this.props.onKeyDown(event);
	    }
	    // Don't propagate the keystroke back to the DOM/browser
	    event.preventDefault();
	  },
	
	  componentWillReceiveProps: function (nextProps) {
	    var searchResults = this.getOptionsForValue(this.state.entryValue, nextProps.options);
	    var showResults = Boolean(searchResults.length) && this.state.isFocused;
	    this.setState({
	      searchResults: searchResults,
	      showResults: showResults
	    });
	  },
	
	  render: function () {
	    var inputClasses = {};
	    inputClasses[this.props.customClasses.input] = !!this.props.customClasses.input;
	    var inputClassList = classNames(inputClasses);
	
	    var classes = {
	      typeahead: this.props.defaultClassNames
	    };
	    classes[this.props.className] = !!this.props.className;
	    var classList = classNames(classes);
	
	    var InputElement = this.props.textarea ? 'textarea' : 'input';
	    return React.createElement(
	      'div',
	      { className: classList },
	      this._renderHiddenInput(),
	      React.createElement(InputElement, _extends({ ref: 'entry', type: 'text',
	        disabled: this.props.disabled
	      }, this.props.inputProps, {
	        placeholder: this.props.placeholder,
	        className: inputClassList,
	        value: this.state.entryValue,
	        onChange: this._onChange,
	        onKeyDown: this._onKeyDown,
	        onKeyPress: this.props.onKeyPress,
	        onKeyUp: this.props.onKeyUp,
	        onFocus: this._onFocus,
	        onBlur: this._onBlur
	      })),
	      this.state.showResults && this._renderIncrementalSearchResults()
	    );
	  },
	
	  _onFocus: function (event) {
	    this.setState({ isFocused: true, showResults: true }, function () {
	      this._onTextEntryUpdated();
	    }.bind(this));
	    if (this.props.onFocus) {
	      return this.props.onFocus(event);
	    }
	  },
	
	  _onBlur: function (event) {
	    this.setState({ isFocused: false }, function () {
	      this._onTextEntryUpdated();
	    }.bind(this));
	    if (this.props.onBlur) {
	      return this.props.onBlur(event);
	    }
	  },
	
	  _renderHiddenInput: function () {
	    if (!this.props.name) {
	      return null;
	    }
	
	    return React.createElement('input', {
	      type: 'hidden',
	      name: this.props.name,
	      value: this.state.selection
	    });
	  },
	
	  _generateSearchFunction: function () {
	    var searchOptionsProp = this.props.searchOptions;
	    var filterOptionProp = this.props.filterOption;
	    if (typeof searchOptionsProp === 'function') {
	      if (filterOptionProp !== null) {
	        console.warn('searchOptions prop is being used, filterOption prop will be ignored');
	      }
	      return searchOptionsProp;
	    } else if (typeof filterOptionProp === 'function') {
	      return function (value, options) {
	        return options.filter(function (o) {
	          return filterOptionProp(value, o);
	        });
	      };
	    } else {
	      var mapper;
	      if (typeof filterOptionProp === 'string') {
	        mapper = Accessor.generateAccessor(filterOptionProp);
	      } else {
	        mapper = Accessor.IDENTITY_FN;
	      }
	      return function (value, options) {
	        return fuzzy.filter(value, options, { extract: mapper }).map(function (res) {
	          return options[res.index];
	        });
	      };
	    }
	  },
	
	  _hasHint: function () {
	    return this.state.searchResults.length > 0 || this._hasCustomValue();
	  }
	});
	
	module.exports = Typeahead;

/***/ }),
/* 5 */
/***/ (function(module, exports) {

	var Accessor = {
	  IDENTITY_FN: function (input) {
	    return input;
	  },
	
	  generateAccessor: function (field) {
	    return function (object) {
	      return object[field];
	    };
	  },
	
	  generateOptionToStringFor: function (prop) {
	    if (typeof prop === 'string') {
	      return this.generateAccessor(prop);
	    } else if (typeof prop === 'function') {
	      return prop;
	    } else {
	      return this.IDENTITY_FN;
	    }
	  },
	
	  valueForOption: function (option, object) {
	    if (typeof option === 'string') {
	      return object[option];
	    } else if (typeof option === 'function') {
	      return option(object);
	    } else {
	      return object;
	    }
	  }
	};
	
	module.exports = Accessor;

/***/ }),
/* 6 */
/***/ (function(module, exports, __webpack_require__) {

	var React = __webpack_require__(1);
	var TypeaheadOption = __webpack_require__(7);
	var classNames = __webpack_require__(8);
	var createReactClass = __webpack_require__(9);
	var PropTypes = __webpack_require__(17);
	
	/**
	 * Container for the options rendered as part of the autocompletion process
	 * of the typeahead
	 */
	var TypeaheadSelector = createReactClass({
	  displayName: 'TypeaheadSelector',
	
	  propTypes: {
	    options: PropTypes.array,
	    allowCustomValues: PropTypes.number,
	    customClasses: PropTypes.object,
	    customValue: PropTypes.string,
	    selectionIndex: PropTypes.number,
	    onOptionSelected: PropTypes.func,
	    displayOption: PropTypes.func.isRequired,
	    defaultClassNames: PropTypes.bool,
	    areResultsTruncated: PropTypes.bool,
	    resultsTruncatedMessage: PropTypes.string
	  },
	
	  getDefaultProps: function () {
	    return {
	      selectionIndex: null,
	      customClasses: {},
	      allowCustomValues: 0,
	      customValue: null,
	      onOptionSelected: function (option) {},
	      defaultClassNames: true
	    };
	  },
	
	  render: function () {
	    // Don't render if there are no options to display
	    if (!this.props.options.length && this.props.allowCustomValues <= 0) {
	      return false;
	    }
	
	    var classes = {
	      "typeahead-selector": this.props.defaultClassNames
	    };
	    classes[this.props.customClasses.results] = this.props.customClasses.results;
	    var classList = classNames(classes);
	
	    // CustomValue should be added to top of results list with different class name
	    var customValue = null;
	    var customValueOffset = 0;
	    if (this.props.customValue !== null) {
	      customValueOffset++;
	      customValue = React.createElement(
	        TypeaheadOption,
	        { ref: this.props.customValue, key: this.props.customValue,
	          hover: this.props.selectionIndex === 0,
	          customClasses: this.props.customClasses,
	          customValue: this.props.customValue,
	          onClick: this._onClick.bind(this, this.props.customValue) },
	        this.props.customValue
	      );
	    }
	
	    var results = this.props.options.map(function (result, i) {
	      var displayString = this.props.displayOption(result, i);
	      var uniqueKey = displayString + '_' + i;
	      return React.createElement(
	        TypeaheadOption,
	        { ref: uniqueKey, key: uniqueKey,
	          hover: this.props.selectionIndex === i + customValueOffset,
	          customClasses: this.props.customClasses,
	          onClick: this._onClick.bind(this, result) },
	        displayString
	      );
	    }, this);
	
	    if (this.props.areResultsTruncated && this.props.resultsTruncatedMessage !== null) {
	      var resultsTruncatedClasses = {
	        "results-truncated": this.props.defaultClassNames
	      };
	      resultsTruncatedClasses[this.props.customClasses.resultsTruncated] = this.props.customClasses.resultsTruncated;
	      var resultsTruncatedClassList = classNames(resultsTruncatedClasses);
	
	      results.push(React.createElement(
	        'li',
	        { key: 'results-truncated', className: resultsTruncatedClassList },
	        this.props.resultsTruncatedMessage
	      ));
	    }
	
	    return React.createElement(
	      'ul',
	      { className: classList },
	      customValue,
	      results
	    );
	  },
	
	  _onClick: function (result, event) {
	    return this.props.onOptionSelected(result, event);
	  }
	
	});
	
	module.exports = TypeaheadSelector;

/***/ }),
/* 7 */
/***/ (function(module, exports, __webpack_require__) {

	var React = __webpack_require__(1);
	var classNames = __webpack_require__(8);
	var createReactClass = __webpack_require__(9);
	var PropTypes = __webpack_require__(17);
	
	/**
	 * A single option within the TypeaheadSelector
	 */
	var TypeaheadOption = createReactClass({
	  displayName: 'TypeaheadOption',
	
	  propTypes: {
	    customClasses: PropTypes.object,
	    customValue: PropTypes.string,
	    onClick: PropTypes.func,
	    children: PropTypes.string,
	    hover: PropTypes.bool
	  },
	
	  getDefaultProps: function () {
	    return {
	      customClasses: {},
	      onClick: function (event) {
	        event.preventDefault();
	      }
	    };
	  },
	
	  render: function () {
	    var classes = {};
	    classes[this.props.customClasses.hover || "hover"] = !!this.props.hover;
	    classes[this.props.customClasses.listItem] = !!this.props.customClasses.listItem;
	
	    if (this.props.customValue) {
	      classes[this.props.customClasses.customAdd] = !!this.props.customClasses.customAdd;
	    }
	
	    var classList = classNames(classes);
	
	    // For some reason onClick is not fired when clicked on an option
	    // onMouseDown is used here as a workaround of #205 and other
	    // related tickets
	    return React.createElement(
	      'li',
	      { className: classList, onClick: this._onClick, onMouseDown: this._onClick },
	      React.createElement(
	        'a',
	        { href: 'javascript: void 0;', className: this._getClasses(), ref: 'anchor' },
	        this.props.children
	      )
	    );
	  },
	
	  _getClasses: function () {
	    var classes = {
	      "typeahead-option": true
	    };
	    classes[this.props.customClasses.listAnchor] = !!this.props.customClasses.listAnchor;
	
	    return classNames(classes);
	  },
	
	  _onClick: function (event) {
	    event.preventDefault();
	    return this.props.onClick(event);
	  }
	});
	
	module.exports = TypeaheadOption;

/***/ }),
/* 8 */
/***/ (function(module, exports, __webpack_require__) {

	var __WEBPACK_AMD_DEFINE_ARRAY__, __WEBPACK_AMD_DEFINE_RESULT__;/*!
	  Copyright (c) 2015 Jed Watson.
	  Licensed under the MIT License (MIT), see
	  http://jedwatson.github.io/classnames
	*/
	
	function classNames() {
		var classes = '';
		var arg;
	
		for (var i = 0; i < arguments.length; i++) {
			arg = arguments[i];
			if (!arg) {
				continue;
			}
	
			if ('string' === typeof arg || 'number' === typeof arg) {
				classes += ' ' + arg;
			} else if (Object.prototype.toString.call(arg) === '[object Array]') {
				classes += ' ' + classNames.apply(null, arg);
			} else if ('object' === typeof arg) {
				for (var key in arg) {
					if (!arg.hasOwnProperty(key) || !arg[key]) {
						continue;
					}
					classes += ' ' + key;
				}
			}
		}
		return classes.substr(1);
	}
	
	// safely export classNames for node / browserify
	if (typeof module !== 'undefined' && module.exports) {
		module.exports = classNames;
	}
	
	// safely export classNames for RequireJS
	if (true) {
		!(__WEBPACK_AMD_DEFINE_ARRAY__ = [], __WEBPACK_AMD_DEFINE_RESULT__ = function() {
			return classNames;
		}.apply(exports, __WEBPACK_AMD_DEFINE_ARRAY__), __WEBPACK_AMD_DEFINE_RESULT__ !== undefined && (module.exports = __WEBPACK_AMD_DEFINE_RESULT__));
	}


/***/ }),
/* 9 */
/***/ (function(module, exports, __webpack_require__) {

	/**
	 * Copyright (c) 2013-present, Facebook, Inc.
	 *
	 * This source code is licensed under the MIT license found in the
	 * LICENSE file in the root directory of this source tree.
	 *
	 */
	
	'use strict';
	
	var React = __webpack_require__(1);
	var factory = __webpack_require__(10);
	
	if (typeof React === 'undefined') {
	  throw Error(
	    'create-react-class could not find the React object. If you are using script tags, ' +
	      'make sure that React is being loaded before create-react-class.'
	  );
	}
	
	// Hack to grab NoopUpdateQueue from isomorphic React
	var ReactNoopUpdateQueue = new React.Component().updater;
	
	module.exports = factory(
	  React.Component,
	  React.isValidElement,
	  ReactNoopUpdateQueue
	);


/***/ }),
/* 10 */
/***/ (function(module, exports, __webpack_require__) {

	/* WEBPACK VAR INJECTION */(function(process) {/**
	 * Copyright (c) 2013-present, Facebook, Inc.
	 *
	 * This source code is licensed under the MIT license found in the
	 * LICENSE file in the root directory of this source tree.
	 *
	 */
	
	'use strict';
	
	var _assign = __webpack_require__(12);
	
	var emptyObject = __webpack_require__(13);
	var _invariant = __webpack_require__(14);
	
	if (process.env.NODE_ENV !== 'production') {
	  var warning = __webpack_require__(15);
	}
	
	var MIXINS_KEY = 'mixins';
	
	// Helper function to allow the creation of anonymous functions which do not
	// have .name set to the name of the variable being assigned to.
	function identity(fn) {
	  return fn;
	}
	
	var ReactPropTypeLocationNames;
	if (process.env.NODE_ENV !== 'production') {
	  ReactPropTypeLocationNames = {
	    prop: 'prop',
	    context: 'context',
	    childContext: 'child context'
	  };
	} else {
	  ReactPropTypeLocationNames = {};
	}
	
	function factory(ReactComponent, isValidElement, ReactNoopUpdateQueue) {
	  /**
	   * Policies that describe methods in `ReactClassInterface`.
	   */
	
	  var injectedMixins = [];
	
	  /**
	   * Composite components are higher-level components that compose other composite
	   * or host components.
	   *
	   * To create a new type of `ReactClass`, pass a specification of
	   * your new class to `React.createClass`. The only requirement of your class
	   * specification is that you implement a `render` method.
	   *
	   *   var MyComponent = React.createClass({
	   *     render: function() {
	   *       return <div>Hello World</div>;
	   *     }
	   *   });
	   *
	   * The class specification supports a specific protocol of methods that have
	   * special meaning (e.g. `render`). See `ReactClassInterface` for
	   * more the comprehensive protocol. Any other properties and methods in the
	   * class specification will be available on the prototype.
	   *
	   * @interface ReactClassInterface
	   * @internal
	   */
	  var ReactClassInterface = {
	    /**
	     * An array of Mixin objects to include when defining your component.
	     *
	     * @type {array}
	     * @optional
	     */
	    mixins: 'DEFINE_MANY',
	
	    /**
	     * An object containing properties and methods that should be defined on
	     * the component's constructor instead of its prototype (static methods).
	     *
	     * @type {object}
	     * @optional
	     */
	    statics: 'DEFINE_MANY',
	
	    /**
	     * Definition of prop types for this component.
	     *
	     * @type {object}
	     * @optional
	     */
	    propTypes: 'DEFINE_MANY',
	
	    /**
	     * Definition of context types for this component.
	     *
	     * @type {object}
	     * @optional
	     */
	    contextTypes: 'DEFINE_MANY',
	
	    /**
	     * Definition of context types this component sets for its children.
	     *
	     * @type {object}
	     * @optional
	     */
	    childContextTypes: 'DEFINE_MANY',
	
	    // ==== Definition methods ====
	
	    /**
	     * Invoked when the component is mounted. Values in the mapping will be set on
	     * `this.props` if that prop is not specified (i.e. using an `in` check).
	     *
	     * This method is invoked before `getInitialState` and therefore cannot rely
	     * on `this.state` or use `this.setState`.
	     *
	     * @return {object}
	     * @optional
	     */
	    getDefaultProps: 'DEFINE_MANY_MERGED',
	
	    /**
	     * Invoked once before the component is mounted. The return value will be used
	     * as the initial value of `this.state`.
	     *
	     *   getInitialState: function() {
	     *     return {
	     *       isOn: false,
	     *       fooBaz: new BazFoo()
	     *     }
	     *   }
	     *
	     * @return {object}
	     * @optional
	     */
	    getInitialState: 'DEFINE_MANY_MERGED',
	
	    /**
	     * @return {object}
	     * @optional
	     */
	    getChildContext: 'DEFINE_MANY_MERGED',
	
	    /**
	     * Uses props from `this.props` and state from `this.state` to render the
	     * structure of the component.
	     *
	     * No guarantees are made about when or how often this method is invoked, so
	     * it must not have side effects.
	     *
	     *   render: function() {
	     *     var name = this.props.name;
	     *     return <div>Hello, {name}!</div>;
	     *   }
	     *
	     * @return {ReactComponent}
	     * @required
	     */
	    render: 'DEFINE_ONCE',
	
	    // ==== Delegate methods ====
	
	    /**
	     * Invoked when the component is initially created and about to be mounted.
	     * This may have side effects, but any external subscriptions or data created
	     * by this method must be cleaned up in `componentWillUnmount`.
	     *
	     * @optional
	     */
	    componentWillMount: 'DEFINE_MANY',
	
	    /**
	     * Invoked when the component has been mounted and has a DOM representation.
	     * However, there is no guarantee that the DOM node is in the document.
	     *
	     * Use this as an opportunity to operate on the DOM when the component has
	     * been mounted (initialized and rendered) for the first time.
	     *
	     * @param {DOMElement} rootNode DOM element representing the component.
	     * @optional
	     */
	    componentDidMount: 'DEFINE_MANY',
	
	    /**
	     * Invoked before the component receives new props.
	     *
	     * Use this as an opportunity to react to a prop transition by updating the
	     * state using `this.setState`. Current props are accessed via `this.props`.
	     *
	     *   componentWillReceiveProps: function(nextProps, nextContext) {
	     *     this.setState({
	     *       likesIncreasing: nextProps.likeCount > this.props.likeCount
	     *     });
	     *   }
	     *
	     * NOTE: There is no equivalent `componentWillReceiveState`. An incoming prop
	     * transition may cause a state change, but the opposite is not true. If you
	     * need it, you are probably looking for `componentWillUpdate`.
	     *
	     * @param {object} nextProps
	     * @optional
	     */
	    componentWillReceiveProps: 'DEFINE_MANY',
	
	    /**
	     * Invoked while deciding if the component should be updated as a result of
	     * receiving new props, state and/or context.
	     *
	     * Use this as an opportunity to `return false` when you're certain that the
	     * transition to the new props/state/context will not require a component
	     * update.
	     *
	     *   shouldComponentUpdate: function(nextProps, nextState, nextContext) {
	     *     return !equal(nextProps, this.props) ||
	     *       !equal(nextState, this.state) ||
	     *       !equal(nextContext, this.context);
	     *   }
	     *
	     * @param {object} nextProps
	     * @param {?object} nextState
	     * @param {?object} nextContext
	     * @return {boolean} True if the component should update.
	     * @optional
	     */
	    shouldComponentUpdate: 'DEFINE_ONCE',
	
	    /**
	     * Invoked when the component is about to update due to a transition from
	     * `this.props`, `this.state` and `this.context` to `nextProps`, `nextState`
	     * and `nextContext`.
	     *
	     * Use this as an opportunity to perform preparation before an update occurs.
	     *
	     * NOTE: You **cannot** use `this.setState()` in this method.
	     *
	     * @param {object} nextProps
	     * @param {?object} nextState
	     * @param {?object} nextContext
	     * @param {ReactReconcileTransaction} transaction
	     * @optional
	     */
	    componentWillUpdate: 'DEFINE_MANY',
	
	    /**
	     * Invoked when the component's DOM representation has been updated.
	     *
	     * Use this as an opportunity to operate on the DOM when the component has
	     * been updated.
	     *
	     * @param {object} prevProps
	     * @param {?object} prevState
	     * @param {?object} prevContext
	     * @param {DOMElement} rootNode DOM element representing the component.
	     * @optional
	     */
	    componentDidUpdate: 'DEFINE_MANY',
	
	    /**
	     * Invoked when the component is about to be removed from its parent and have
	     * its DOM representation destroyed.
	     *
	     * Use this as an opportunity to deallocate any external resources.
	     *
	     * NOTE: There is no `componentDidUnmount` since your component will have been
	     * destroyed by that point.
	     *
	     * @optional
	     */
	    componentWillUnmount: 'DEFINE_MANY',
	
	    /**
	     * Replacement for (deprecated) `componentWillMount`.
	     *
	     * @optional
	     */
	    UNSAFE_componentWillMount: 'DEFINE_MANY',
	
	    /**
	     * Replacement for (deprecated) `componentWillReceiveProps`.
	     *
	     * @optional
	     */
	    UNSAFE_componentWillReceiveProps: 'DEFINE_MANY',
	
	    /**
	     * Replacement for (deprecated) `componentWillUpdate`.
	     *
	     * @optional
	     */
	    UNSAFE_componentWillUpdate: 'DEFINE_MANY',
	
	    // ==== Advanced methods ====
	
	    /**
	     * Updates the component's currently mounted DOM representation.
	     *
	     * By default, this implements React's rendering and reconciliation algorithm.
	     * Sophisticated clients may wish to override this.
	     *
	     * @param {ReactReconcileTransaction} transaction
	     * @internal
	     * @overridable
	     */
	    updateComponent: 'OVERRIDE_BASE'
	  };
	
	  /**
	   * Similar to ReactClassInterface but for static methods.
	   */
	  var ReactClassStaticInterface = {
	    /**
	     * This method is invoked after a component is instantiated and when it
	     * receives new props. Return an object to update state in response to
	     * prop changes. Return null to indicate no change to state.
	     *
	     * If an object is returned, its keys will be merged into the existing state.
	     *
	     * @return {object || null}
	     * @optional
	     */
	    getDerivedStateFromProps: 'DEFINE_MANY_MERGED'
	  };
	
	  /**
	   * Mapping from class specification keys to special processing functions.
	   *
	   * Although these are declared like instance properties in the specification
	   * when defining classes using `React.createClass`, they are actually static
	   * and are accessible on the constructor instead of the prototype. Despite
	   * being static, they must be defined outside of the "statics" key under
	   * which all other static methods are defined.
	   */
	  var RESERVED_SPEC_KEYS = {
	    displayName: function(Constructor, displayName) {
	      Constructor.displayName = displayName;
	    },
	    mixins: function(Constructor, mixins) {
	      if (mixins) {
	        for (var i = 0; i < mixins.length; i++) {
	          mixSpecIntoComponent(Constructor, mixins[i]);
	        }
	      }
	    },
	    childContextTypes: function(Constructor, childContextTypes) {
	      if (process.env.NODE_ENV !== 'production') {
	        validateTypeDef(Constructor, childContextTypes, 'childContext');
	      }
	      Constructor.childContextTypes = _assign(
	        {},
	        Constructor.childContextTypes,
	        childContextTypes
	      );
	    },
	    contextTypes: function(Constructor, contextTypes) {
	      if (process.env.NODE_ENV !== 'production') {
	        validateTypeDef(Constructor, contextTypes, 'context');
	      }
	      Constructor.contextTypes = _assign(
	        {},
	        Constructor.contextTypes,
	        contextTypes
	      );
	    },
	    /**
	     * Special case getDefaultProps which should move into statics but requires
	     * automatic merging.
	     */
	    getDefaultProps: function(Constructor, getDefaultProps) {
	      if (Constructor.getDefaultProps) {
	        Constructor.getDefaultProps = createMergedResultFunction(
	          Constructor.getDefaultProps,
	          getDefaultProps
	        );
	      } else {
	        Constructor.getDefaultProps = getDefaultProps;
	      }
	    },
	    propTypes: function(Constructor, propTypes) {
	      if (process.env.NODE_ENV !== 'production') {
	        validateTypeDef(Constructor, propTypes, 'prop');
	      }
	      Constructor.propTypes = _assign({}, Constructor.propTypes, propTypes);
	    },
	    statics: function(Constructor, statics) {
	      mixStaticSpecIntoComponent(Constructor, statics);
	    },
	    autobind: function() {}
	  };
	
	  function validateTypeDef(Constructor, typeDef, location) {
	    for (var propName in typeDef) {
	      if (typeDef.hasOwnProperty(propName)) {
	        // use a warning instead of an _invariant so components
	        // don't show up in prod but only in __DEV__
	        if (process.env.NODE_ENV !== 'production') {
	          warning(
	            typeof typeDef[propName] === 'function',
	            '%s: %s type `%s` is invalid; it must be a function, usually from ' +
	              'React.PropTypes.',
	            Constructor.displayName || 'ReactClass',
	            ReactPropTypeLocationNames[location],
	            propName
	          );
	        }
	      }
	    }
	  }
	
	  function validateMethodOverride(isAlreadyDefined, name) {
	    var specPolicy = ReactClassInterface.hasOwnProperty(name)
	      ? ReactClassInterface[name]
	      : null;
	
	    // Disallow overriding of base class methods unless explicitly allowed.
	    if (ReactClassMixin.hasOwnProperty(name)) {
	      _invariant(
	        specPolicy === 'OVERRIDE_BASE',
	        'ReactClassInterface: You are attempting to override ' +
	          '`%s` from your class specification. Ensure that your method names ' +
	          'do not overlap with React methods.',
	        name
	      );
	    }
	
	    // Disallow defining methods more than once unless explicitly allowed.
	    if (isAlreadyDefined) {
	      _invariant(
	        specPolicy === 'DEFINE_MANY' || specPolicy === 'DEFINE_MANY_MERGED',
	        'ReactClassInterface: You are attempting to define ' +
	          '`%s` on your component more than once. This conflict may be due ' +
	          'to a mixin.',
	        name
	      );
	    }
	  }
	
	  /**
	   * Mixin helper which handles policy validation and reserved
	   * specification keys when building React classes.
	   */
	  function mixSpecIntoComponent(Constructor, spec) {
	    if (!spec) {
	      if (process.env.NODE_ENV !== 'production') {
	        var typeofSpec = typeof spec;
	        var isMixinValid = typeofSpec === 'object' && spec !== null;
	
	        if (process.env.NODE_ENV !== 'production') {
	          warning(
	            isMixinValid,
	            "%s: You're attempting to include a mixin that is either null " +
	              'or not an object. Check the mixins included by the component, ' +
	              'as well as any mixins they include themselves. ' +
	              'Expected object but got %s.',
	            Constructor.displayName || 'ReactClass',
	            spec === null ? null : typeofSpec
	          );
	        }
	      }
	
	      return;
	    }
	
	    _invariant(
	      typeof spec !== 'function',
	      "ReactClass: You're attempting to " +
	        'use a component class or function as a mixin. Instead, just use a ' +
	        'regular object.'
	    );
	    _invariant(
	      !isValidElement(spec),
	      "ReactClass: You're attempting to " +
	        'use a component as a mixin. Instead, just use a regular object.'
	    );
	
	    var proto = Constructor.prototype;
	    var autoBindPairs = proto.__reactAutoBindPairs;
	
	    // By handling mixins before any other properties, we ensure the same
	    // chaining order is applied to methods with DEFINE_MANY policy, whether
	    // mixins are listed before or after these methods in the spec.
	    if (spec.hasOwnProperty(MIXINS_KEY)) {
	      RESERVED_SPEC_KEYS.mixins(Constructor, spec.mixins);
	    }
	
	    for (var name in spec) {
	      if (!spec.hasOwnProperty(name)) {
	        continue;
	      }
	
	      if (name === MIXINS_KEY) {
	        // We have already handled mixins in a special case above.
	        continue;
	      }
	
	      var property = spec[name];
	      var isAlreadyDefined = proto.hasOwnProperty(name);
	      validateMethodOverride(isAlreadyDefined, name);
	
	      if (RESERVED_SPEC_KEYS.hasOwnProperty(name)) {
	        RESERVED_SPEC_KEYS[name](Constructor, property);
	      } else {
	        // Setup methods on prototype:
	        // The following member methods should not be automatically bound:
	        // 1. Expected ReactClass methods (in the "interface").
	        // 2. Overridden methods (that were mixed in).
	        var isReactClassMethod = ReactClassInterface.hasOwnProperty(name);
	        var isFunction = typeof property === 'function';
	        var shouldAutoBind =
	          isFunction &&
	          !isReactClassMethod &&
	          !isAlreadyDefined &&
	          spec.autobind !== false;
	
	        if (shouldAutoBind) {
	          autoBindPairs.push(name, property);
	          proto[name] = property;
	        } else {
	          if (isAlreadyDefined) {
	            var specPolicy = ReactClassInterface[name];
	
	            // These cases should already be caught by validateMethodOverride.
	            _invariant(
	              isReactClassMethod &&
	                (specPolicy === 'DEFINE_MANY_MERGED' ||
	                  specPolicy === 'DEFINE_MANY'),
	              'ReactClass: Unexpected spec policy %s for key %s ' +
	                'when mixing in component specs.',
	              specPolicy,
	              name
	            );
	
	            // For methods which are defined more than once, call the existing
	            // methods before calling the new property, merging if appropriate.
	            if (specPolicy === 'DEFINE_MANY_MERGED') {
	              proto[name] = createMergedResultFunction(proto[name], property);
	            } else if (specPolicy === 'DEFINE_MANY') {
	              proto[name] = createChainedFunction(proto[name], property);
	            }
	          } else {
	            proto[name] = property;
	            if (process.env.NODE_ENV !== 'production') {
	              // Add verbose displayName to the function, which helps when looking
	              // at profiling tools.
	              if (typeof property === 'function' && spec.displayName) {
	                proto[name].displayName = spec.displayName + '_' + name;
	              }
	            }
	          }
	        }
	      }
	    }
	  }
	
	  function mixStaticSpecIntoComponent(Constructor, statics) {
	    if (!statics) {
	      return;
	    }
	
	    for (var name in statics) {
	      var property = statics[name];
	      if (!statics.hasOwnProperty(name)) {
	        continue;
	      }
	
	      var isReserved = name in RESERVED_SPEC_KEYS;
	      _invariant(
	        !isReserved,
	        'ReactClass: You are attempting to define a reserved ' +
	          'property, `%s`, that shouldn\'t be on the "statics" key. Define it ' +
	          'as an instance property instead; it will still be accessible on the ' +
	          'constructor.',
	        name
	      );
	
	      var isAlreadyDefined = name in Constructor;
	      if (isAlreadyDefined) {
	        var specPolicy = ReactClassStaticInterface.hasOwnProperty(name)
	          ? ReactClassStaticInterface[name]
	          : null;
	
	        _invariant(
	          specPolicy === 'DEFINE_MANY_MERGED',
	          'ReactClass: You are attempting to define ' +
	            '`%s` on your component more than once. This conflict may be ' +
	            'due to a mixin.',
	          name
	        );
	
	        Constructor[name] = createMergedResultFunction(Constructor[name], property);
	
	        return;
	      }
	
	      Constructor[name] = property;
	    }
	  }
	
	  /**
	   * Merge two objects, but throw if both contain the same key.
	   *
	   * @param {object} one The first object, which is mutated.
	   * @param {object} two The second object
	   * @return {object} one after it has been mutated to contain everything in two.
	   */
	  function mergeIntoWithNoDuplicateKeys(one, two) {
	    _invariant(
	      one && two && typeof one === 'object' && typeof two === 'object',
	      'mergeIntoWithNoDuplicateKeys(): Cannot merge non-objects.'
	    );
	
	    for (var key in two) {
	      if (two.hasOwnProperty(key)) {
	        _invariant(
	          one[key] === undefined,
	          'mergeIntoWithNoDuplicateKeys(): ' +
	            'Tried to merge two objects with the same key: `%s`. This conflict ' +
	            'may be due to a mixin; in particular, this may be caused by two ' +
	            'getInitialState() or getDefaultProps() methods returning objects ' +
	            'with clashing keys.',
	          key
	        );
	        one[key] = two[key];
	      }
	    }
	    return one;
	  }
	
	  /**
	   * Creates a function that invokes two functions and merges their return values.
	   *
	   * @param {function} one Function to invoke first.
	   * @param {function} two Function to invoke second.
	   * @return {function} Function that invokes the two argument functions.
	   * @private
	   */
	  function createMergedResultFunction(one, two) {
	    return function mergedResult() {
	      var a = one.apply(this, arguments);
	      var b = two.apply(this, arguments);
	      if (a == null) {
	        return b;
	      } else if (b == null) {
	        return a;
	      }
	      var c = {};
	      mergeIntoWithNoDuplicateKeys(c, a);
	      mergeIntoWithNoDuplicateKeys(c, b);
	      return c;
	    };
	  }
	
	  /**
	   * Creates a function that invokes two functions and ignores their return vales.
	   *
	   * @param {function} one Function to invoke first.
	   * @param {function} two Function to invoke second.
	   * @return {function} Function that invokes the two argument functions.
	   * @private
	   */
	  function createChainedFunction(one, two) {
	    return function chainedFunction() {
	      one.apply(this, arguments);
	      two.apply(this, arguments);
	    };
	  }
	
	  /**
	   * Binds a method to the component.
	   *
	   * @param {object} component Component whose method is going to be bound.
	   * @param {function} method Method to be bound.
	   * @return {function} The bound method.
	   */
	  function bindAutoBindMethod(component, method) {
	    var boundMethod = method.bind(component);
	    if (process.env.NODE_ENV !== 'production') {
	      boundMethod.__reactBoundContext = component;
	      boundMethod.__reactBoundMethod = method;
	      boundMethod.__reactBoundArguments = null;
	      var componentName = component.constructor.displayName;
	      var _bind = boundMethod.bind;
	      boundMethod.bind = function(newThis) {
	        for (
	          var _len = arguments.length,
	            args = Array(_len > 1 ? _len - 1 : 0),
	            _key = 1;
	          _key < _len;
	          _key++
	        ) {
	          args[_key - 1] = arguments[_key];
	        }
	
	        // User is trying to bind() an autobound method; we effectively will
	        // ignore the value of "this" that the user is trying to use, so
	        // let's warn.
	        if (newThis !== component && newThis !== null) {
	          if (process.env.NODE_ENV !== 'production') {
	            warning(
	              false,
	              'bind(): React component methods may only be bound to the ' +
	                'component instance. See %s',
	              componentName
	            );
	          }
	        } else if (!args.length) {
	          if (process.env.NODE_ENV !== 'production') {
	            warning(
	              false,
	              'bind(): You are binding a component method to the component. ' +
	                'React does this for you automatically in a high-performance ' +
	                'way, so you can safely remove this call. See %s',
	              componentName
	            );
	          }
	          return boundMethod;
	        }
	        var reboundMethod = _bind.apply(boundMethod, arguments);
	        reboundMethod.__reactBoundContext = component;
	        reboundMethod.__reactBoundMethod = method;
	        reboundMethod.__reactBoundArguments = args;
	        return reboundMethod;
	      };
	    }
	    return boundMethod;
	  }
	
	  /**
	   * Binds all auto-bound methods in a component.
	   *
	   * @param {object} component Component whose method is going to be bound.
	   */
	  function bindAutoBindMethods(component) {
	    var pairs = component.__reactAutoBindPairs;
	    for (var i = 0; i < pairs.length; i += 2) {
	      var autoBindKey = pairs[i];
	      var method = pairs[i + 1];
	      component[autoBindKey] = bindAutoBindMethod(component, method);
	    }
	  }
	
	  var IsMountedPreMixin = {
	    componentDidMount: function() {
	      this.__isMounted = true;
	    }
	  };
	
	  var IsMountedPostMixin = {
	    componentWillUnmount: function() {
	      this.__isMounted = false;
	    }
	  };
	
	  /**
	   * Add more to the ReactClass base class. These are all legacy features and
	   * therefore not already part of the modern ReactComponent.
	   */
	  var ReactClassMixin = {
	    /**
	     * TODO: This will be deprecated because state should always keep a consistent
	     * type signature and the only use case for this, is to avoid that.
	     */
	    replaceState: function(newState, callback) {
	      this.updater.enqueueReplaceState(this, newState, callback);
	    },
	
	    /**
	     * Checks whether or not this composite component is mounted.
	     * @return {boolean} True if mounted, false otherwise.
	     * @protected
	     * @final
	     */
	    isMounted: function() {
	      if (process.env.NODE_ENV !== 'production') {
	        warning(
	          this.__didWarnIsMounted,
	          '%s: isMounted is deprecated. Instead, make sure to clean up ' +
	            'subscriptions and pending requests in componentWillUnmount to ' +
	            'prevent memory leaks.',
	          (this.constructor && this.constructor.displayName) ||
	            this.name ||
	            'Component'
	        );
	        this.__didWarnIsMounted = true;
	      }
	      return !!this.__isMounted;
	    }
	  };
	
	  var ReactClassComponent = function() {};
	  _assign(
	    ReactClassComponent.prototype,
	    ReactComponent.prototype,
	    ReactClassMixin
	  );
	
	  /**
	   * Creates a composite component class given a class specification.
	   * See https://facebook.github.io/react/docs/top-level-api.html#react.createclass
	   *
	   * @param {object} spec Class specification (which must define `render`).
	   * @return {function} Component constructor function.
	   * @public
	   */
	  function createClass(spec) {
	    // To keep our warnings more understandable, we'll use a little hack here to
	    // ensure that Constructor.name !== 'Constructor'. This makes sure we don't
	    // unnecessarily identify a class without displayName as 'Constructor'.
	    var Constructor = identity(function(props, context, updater) {
	      // This constructor gets overridden by mocks. The argument is used
	      // by mocks to assert on what gets mounted.
	
	      if (process.env.NODE_ENV !== 'production') {
	        warning(
	          this instanceof Constructor,
	          'Something is calling a React component directly. Use a factory or ' +
	            'JSX instead. See: https://fb.me/react-legacyfactory'
	        );
	      }
	
	      // Wire up auto-binding
	      if (this.__reactAutoBindPairs.length) {
	        bindAutoBindMethods(this);
	      }
	
	      this.props = props;
	      this.context = context;
	      this.refs = emptyObject;
	      this.updater = updater || ReactNoopUpdateQueue;
	
	      this.state = null;
	
	      // ReactClasses doesn't have constructors. Instead, they use the
	      // getInitialState and componentWillMount methods for initialization.
	
	      var initialState = this.getInitialState ? this.getInitialState() : null;
	      if (process.env.NODE_ENV !== 'production') {
	        // We allow auto-mocks to proceed as if they're returning null.
	        if (
	          initialState === undefined &&
	          this.getInitialState._isMockFunction
	        ) {
	          // This is probably bad practice. Consider warning here and
	          // deprecating this convenience.
	          initialState = null;
	        }
	      }
	      _invariant(
	        typeof initialState === 'object' && !Array.isArray(initialState),
	        '%s.getInitialState(): must return an object or null',
	        Constructor.displayName || 'ReactCompositeComponent'
	      );
	
	      this.state = initialState;
	    });
	    Constructor.prototype = new ReactClassComponent();
	    Constructor.prototype.constructor = Constructor;
	    Constructor.prototype.__reactAutoBindPairs = [];
	
	    injectedMixins.forEach(mixSpecIntoComponent.bind(null, Constructor));
	
	    mixSpecIntoComponent(Constructor, IsMountedPreMixin);
	    mixSpecIntoComponent(Constructor, spec);
	    mixSpecIntoComponent(Constructor, IsMountedPostMixin);
	
	    // Initialize the defaultProps property after all mixins have been merged.
	    if (Constructor.getDefaultProps) {
	      Constructor.defaultProps = Constructor.getDefaultProps();
	    }
	
	    if (process.env.NODE_ENV !== 'production') {
	      // This is a tag to indicate that the use of these method names is ok,
	      // since it's used with createClass. If it's not, then it's likely a
	      // mistake so we'll warn you to use the static property, property
	      // initializer or constructor respectively.
	      if (Constructor.getDefaultProps) {
	        Constructor.getDefaultProps.isReactClassApproved = {};
	      }
	      if (Constructor.prototype.getInitialState) {
	        Constructor.prototype.getInitialState.isReactClassApproved = {};
	      }
	    }
	
	    _invariant(
	      Constructor.prototype.render,
	      'createClass(...): Class specification must implement a `render` method.'
	    );
	
	    if (process.env.NODE_ENV !== 'production') {
	      warning(
	        !Constructor.prototype.componentShouldUpdate,
	        '%s has a method called ' +
	          'componentShouldUpdate(). Did you mean shouldComponentUpdate()? ' +
	          'The name is phrased as a question because the function is ' +
	          'expected to return a value.',
	        spec.displayName || 'A component'
	      );
	      warning(
	        !Constructor.prototype.componentWillRecieveProps,
	        '%s has a method called ' +
	          'componentWillRecieveProps(). Did you mean componentWillReceiveProps()?',
	        spec.displayName || 'A component'
	      );
	      warning(
	        !Constructor.prototype.UNSAFE_componentWillRecieveProps,
	        '%s has a method called UNSAFE_componentWillRecieveProps(). ' +
	          'Did you mean UNSAFE_componentWillReceiveProps()?',
	        spec.displayName || 'A component'
	      );
	    }
	
	    // Reduce time spent doing lookups by setting these on the prototype.
	    for (var methodName in ReactClassInterface) {
	      if (!Constructor.prototype[methodName]) {
	        Constructor.prototype[methodName] = null;
	      }
	    }
	
	    return Constructor;
	  }
	
	  return createClass;
	}
	
	module.exports = factory;
	
	/* WEBPACK VAR INJECTION */}.call(exports, __webpack_require__(11)))

/***/ }),
/* 11 */
/***/ (function(module, exports) {

	// shim for using process in browser
	var process = module.exports = {};
	
	// cached from whatever global is present so that test runners that stub it
	// don't break things.  But we need to wrap it in a try catch in case it is
	// wrapped in strict mode code which doesn't define any globals.  It's inside a
	// function because try/catches deoptimize in certain engines.
	
	var cachedSetTimeout;
	var cachedClearTimeout;
	
	function defaultSetTimout() {
	    throw new Error('setTimeout has not been defined');
	}
	function defaultClearTimeout () {
	    throw new Error('clearTimeout has not been defined');
	}
	(function () {
	    try {
	        if (typeof setTimeout === 'function') {
	            cachedSetTimeout = setTimeout;
	        } else {
	            cachedSetTimeout = defaultSetTimout;
	        }
	    } catch (e) {
	        cachedSetTimeout = defaultSetTimout;
	    }
	    try {
	        if (typeof clearTimeout === 'function') {
	            cachedClearTimeout = clearTimeout;
	        } else {
	            cachedClearTimeout = defaultClearTimeout;
	        }
	    } catch (e) {
	        cachedClearTimeout = defaultClearTimeout;
	    }
	} ())
	function runTimeout(fun) {
	    if (cachedSetTimeout === setTimeout) {
	        //normal enviroments in sane situations
	        return setTimeout(fun, 0);
	    }
	    // if setTimeout wasn't available but was latter defined
	    if ((cachedSetTimeout === defaultSetTimout || !cachedSetTimeout) && setTimeout) {
	        cachedSetTimeout = setTimeout;
	        return setTimeout(fun, 0);
	    }
	    try {
	        // when when somebody has screwed with setTimeout but no I.E. maddness
	        return cachedSetTimeout(fun, 0);
	    } catch(e){
	        try {
	            // When we are in I.E. but the script has been evaled so I.E. doesn't trust the global object when called normally
	            return cachedSetTimeout.call(null, fun, 0);
	        } catch(e){
	            // same as above but when it's a version of I.E. that must have the global object for 'this', hopfully our context correct otherwise it will throw a global error
	            return cachedSetTimeout.call(this, fun, 0);
	        }
	    }
	
	
	}
	function runClearTimeout(marker) {
	    if (cachedClearTimeout === clearTimeout) {
	        //normal enviroments in sane situations
	        return clearTimeout(marker);
	    }
	    // if clearTimeout wasn't available but was latter defined
	    if ((cachedClearTimeout === defaultClearTimeout || !cachedClearTimeout) && clearTimeout) {
	        cachedClearTimeout = clearTimeout;
	        return clearTimeout(marker);
	    }
	    try {
	        // when when somebody has screwed with setTimeout but no I.E. maddness
	        return cachedClearTimeout(marker);
	    } catch (e){
	        try {
	            // When we are in I.E. but the script has been evaled so I.E. doesn't  trust the global object when called normally
	            return cachedClearTimeout.call(null, marker);
	        } catch (e){
	            // same as above but when it's a version of I.E. that must have the global object for 'this', hopfully our context correct otherwise it will throw a global error.
	            // Some versions of I.E. have different rules for clearTimeout vs setTimeout
	            return cachedClearTimeout.call(this, marker);
	        }
	    }
	
	
	
	}
	var queue = [];
	var draining = false;
	var currentQueue;
	var queueIndex = -1;
	
	function cleanUpNextTick() {
	    if (!draining || !currentQueue) {
	        return;
	    }
	    draining = false;
	    if (currentQueue.length) {
	        queue = currentQueue.concat(queue);
	    } else {
	        queueIndex = -1;
	    }
	    if (queue.length) {
	        drainQueue();
	    }
	}
	
	function drainQueue() {
	    if (draining) {
	        return;
	    }
	    var timeout = runTimeout(cleanUpNextTick);
	    draining = true;
	
	    var len = queue.length;
	    while(len) {
	        currentQueue = queue;
	        queue = [];
	        while (++queueIndex < len) {
	            if (currentQueue) {
	                currentQueue[queueIndex].run();
	            }
	        }
	        queueIndex = -1;
	        len = queue.length;
	    }
	    currentQueue = null;
	    draining = false;
	    runClearTimeout(timeout);
	}
	
	process.nextTick = function (fun) {
	    var args = new Array(arguments.length - 1);
	    if (arguments.length > 1) {
	        for (var i = 1; i < arguments.length; i++) {
	            args[i - 1] = arguments[i];
	        }
	    }
	    queue.push(new Item(fun, args));
	    if (queue.length === 1 && !draining) {
	        runTimeout(drainQueue);
	    }
	};
	
	// v8 likes predictible objects
	function Item(fun, array) {
	    this.fun = fun;
	    this.array = array;
	}
	Item.prototype.run = function () {
	    this.fun.apply(null, this.array);
	};
	process.title = 'browser';
	process.browser = true;
	process.env = {};
	process.argv = [];
	process.version = ''; // empty string to avoid regexp issues
	process.versions = {};
	
	function noop() {}
	
	process.on = noop;
	process.addListener = noop;
	process.once = noop;
	process.off = noop;
	process.removeListener = noop;
	process.removeAllListeners = noop;
	process.emit = noop;
	process.prependListener = noop;
	process.prependOnceListener = noop;
	
	process.listeners = function (name) { return [] }
	
	process.binding = function (name) {
	    throw new Error('process.binding is not supported');
	};
	
	process.cwd = function () { return '/' };
	process.chdir = function (dir) {
	    throw new Error('process.chdir is not supported');
	};
	process.umask = function() { return 0; };


/***/ }),
/* 12 */
/***/ (function(module, exports) {

	/*
	object-assign
	(c) Sindre Sorhus
	@license MIT
	*/
	
	'use strict';
	/* eslint-disable no-unused-vars */
	var getOwnPropertySymbols = Object.getOwnPropertySymbols;
	var hasOwnProperty = Object.prototype.hasOwnProperty;
	var propIsEnumerable = Object.prototype.propertyIsEnumerable;
	
	function toObject(val) {
		if (val === null || val === undefined) {
			throw new TypeError('Object.assign cannot be called with null or undefined');
		}
	
		return Object(val);
	}
	
	function shouldUseNative() {
		try {
			if (!Object.assign) {
				return false;
			}
	
			// Detect buggy property enumeration order in older V8 versions.
	
			// https://bugs.chromium.org/p/v8/issues/detail?id=4118
			var test1 = new String('abc');  // eslint-disable-line no-new-wrappers
			test1[5] = 'de';
			if (Object.getOwnPropertyNames(test1)[0] === '5') {
				return false;
			}
	
			// https://bugs.chromium.org/p/v8/issues/detail?id=3056
			var test2 = {};
			for (var i = 0; i < 10; i++) {
				test2['_' + String.fromCharCode(i)] = i;
			}
			var order2 = Object.getOwnPropertyNames(test2).map(function (n) {
				return test2[n];
			});
			if (order2.join('') !== '0123456789') {
				return false;
			}
	
			// https://bugs.chromium.org/p/v8/issues/detail?id=3056
			var test3 = {};
			'abcdefghijklmnopqrst'.split('').forEach(function (letter) {
				test3[letter] = letter;
			});
			if (Object.keys(Object.assign({}, test3)).join('') !==
					'abcdefghijklmnopqrst') {
				return false;
			}
	
			return true;
		} catch (err) {
			// We don't expect any of the above to throw, but better to be safe.
			return false;
		}
	}
	
	module.exports = shouldUseNative() ? Object.assign : function (target, source) {
		var from;
		var to = toObject(target);
		var symbols;
	
		for (var s = 1; s < arguments.length; s++) {
			from = Object(arguments[s]);
	
			for (var key in from) {
				if (hasOwnProperty.call(from, key)) {
					to[key] = from[key];
				}
			}
	
			if (getOwnPropertySymbols) {
				symbols = getOwnPropertySymbols(from);
				for (var i = 0; i < symbols.length; i++) {
					if (propIsEnumerable.call(from, symbols[i])) {
						to[symbols[i]] = from[symbols[i]];
					}
				}
			}
		}
	
		return to;
	};


/***/ }),
/* 13 */
/***/ (function(module, exports, __webpack_require__) {

	/* WEBPACK VAR INJECTION */(function(process) {/**
	 * Copyright (c) 2013-present, Facebook, Inc.
	 *
	 * This source code is licensed under the MIT license found in the
	 * LICENSE file in the root directory of this source tree.
	 *
	 */
	
	'use strict';
	
	var emptyObject = {};
	
	if (process.env.NODE_ENV !== 'production') {
	  Object.freeze(emptyObject);
	}
	
	module.exports = emptyObject;
	/* WEBPACK VAR INJECTION */}.call(exports, __webpack_require__(11)))

/***/ }),
/* 14 */
/***/ (function(module, exports, __webpack_require__) {

	/* WEBPACK VAR INJECTION */(function(process) {/**
	 * Copyright (c) 2013-present, Facebook, Inc.
	 *
	 * This source code is licensed under the MIT license found in the
	 * LICENSE file in the root directory of this source tree.
	 *
	 */
	
	'use strict';
	
	/**
	 * Use invariant() to assert state which your program assumes to be true.
	 *
	 * Provide sprintf-style format (only %s is supported) and arguments
	 * to provide information about what broke and what you were
	 * expecting.
	 *
	 * The invariant message will be stripped in production, but the invariant
	 * will remain to ensure logic does not differ in production.
	 */
	
	var validateFormat = function validateFormat(format) {};
	
	if (process.env.NODE_ENV !== 'production') {
	  validateFormat = function validateFormat(format) {
	    if (format === undefined) {
	      throw new Error('invariant requires an error message argument');
	    }
	  };
	}
	
	function invariant(condition, format, a, b, c, d, e, f) {
	  validateFormat(format);
	
	  if (!condition) {
	    var error;
	    if (format === undefined) {
	      error = new Error('Minified exception occurred; use the non-minified dev environment ' + 'for the full error message and additional helpful warnings.');
	    } else {
	      var args = [a, b, c, d, e, f];
	      var argIndex = 0;
	      error = new Error(format.replace(/%s/g, function () {
	        return args[argIndex++];
	      }));
	      error.name = 'Invariant Violation';
	    }
	
	    error.framesToPop = 1; // we don't care about invariant's own frame
	    throw error;
	  }
	}
	
	module.exports = invariant;
	/* WEBPACK VAR INJECTION */}.call(exports, __webpack_require__(11)))

/***/ }),
/* 15 */
/***/ (function(module, exports, __webpack_require__) {

	/* WEBPACK VAR INJECTION */(function(process) {/**
	 * Copyright (c) 2014-present, Facebook, Inc.
	 *
	 * This source code is licensed under the MIT license found in the
	 * LICENSE file in the root directory of this source tree.
	 *
	 */
	
	'use strict';
	
	var emptyFunction = __webpack_require__(16);
	
	/**
	 * Similar to invariant but only logs a warning if the condition is not met.
	 * This can be used to log issues in development environments in critical
	 * paths. Removing the logging code for production environments will keep the
	 * same logic and follow the same code paths.
	 */
	
	var warning = emptyFunction;
	
	if (process.env.NODE_ENV !== 'production') {
	  var printWarning = function printWarning(format) {
	    for (var _len = arguments.length, args = Array(_len > 1 ? _len - 1 : 0), _key = 1; _key < _len; _key++) {
	      args[_key - 1] = arguments[_key];
	    }
	
	    var argIndex = 0;
	    var message = 'Warning: ' + format.replace(/%s/g, function () {
	      return args[argIndex++];
	    });
	    if (typeof console !== 'undefined') {
	      console.error(message);
	    }
	    try {
	      // --- Welcome to debugging React ---
	      // This error was thrown as a convenience so that you can use this stack
	      // to find the callsite that caused this warning to fire.
	      throw new Error(message);
	    } catch (x) {}
	  };
	
	  warning = function warning(condition, format) {
	    if (format === undefined) {
	      throw new Error('`warning(condition, format, ...args)` requires a warning ' + 'message argument');
	    }
	
	    if (format.indexOf('Failed Composite propType: ') === 0) {
	      return; // Ignore CompositeComponent proptype check.
	    }
	
	    if (!condition) {
	      for (var _len2 = arguments.length, args = Array(_len2 > 2 ? _len2 - 2 : 0), _key2 = 2; _key2 < _len2; _key2++) {
	        args[_key2 - 2] = arguments[_key2];
	      }
	
	      printWarning.apply(undefined, [format].concat(args));
	    }
	  };
	}
	
	module.exports = warning;
	/* WEBPACK VAR INJECTION */}.call(exports, __webpack_require__(11)))

/***/ }),
/* 16 */
/***/ (function(module, exports) {

	"use strict";
	
	/**
	 * Copyright (c) 2013-present, Facebook, Inc.
	 *
	 * This source code is licensed under the MIT license found in the
	 * LICENSE file in the root directory of this source tree.
	 *
	 * 
	 */
	
	function makeEmptyFunction(arg) {
	  return function () {
	    return arg;
	  };
	}
	
	/**
	 * This function accepts and discards inputs; it has no side effects. This is
	 * primarily useful idiomatically for overridable function endpoints which
	 * always need to be callable, since JS lacks a null-call idiom ala Cocoa.
	 */
	var emptyFunction = function emptyFunction() {};
	
	emptyFunction.thatReturns = makeEmptyFunction;
	emptyFunction.thatReturnsFalse = makeEmptyFunction(false);
	emptyFunction.thatReturnsTrue = makeEmptyFunction(true);
	emptyFunction.thatReturnsNull = makeEmptyFunction(null);
	emptyFunction.thatReturnsThis = function () {
	  return this;
	};
	emptyFunction.thatReturnsArgument = function (arg) {
	  return arg;
	};
	
	module.exports = emptyFunction;

/***/ }),
/* 17 */
/***/ (function(module, exports, __webpack_require__) {

	/* WEBPACK VAR INJECTION */(function(process) {/**
	 * Copyright (c) 2013-present, Facebook, Inc.
	 *
	 * This source code is licensed under the MIT license found in the
	 * LICENSE file in the root directory of this source tree.
	 */
	
	if (process.env.NODE_ENV !== 'production') {
	  var ReactIs = __webpack_require__(18);
	
	  // By explicitly using `prop-types` you are opting into new development behavior.
	  // http://fb.me/prop-types-in-prod
	  var throwOnDirectAccess = true;
	  module.exports = __webpack_require__(21)(ReactIs.isElement, throwOnDirectAccess);
	} else {
	  // By explicitly using `prop-types` you are opting into new production behavior.
	  // http://fb.me/prop-types-in-prod
	  module.exports = __webpack_require__(24)();
	}
	
	/* WEBPACK VAR INJECTION */}.call(exports, __webpack_require__(11)))

/***/ }),
/* 18 */
/***/ (function(module, exports, __webpack_require__) {

	/* WEBPACK VAR INJECTION */(function(process) {'use strict';
	
	if (process.env.NODE_ENV === 'production') {
	  module.exports = __webpack_require__(19);
	} else {
	  module.exports = __webpack_require__(20);
	}
	
	/* WEBPACK VAR INJECTION */}.call(exports, __webpack_require__(11)))

/***/ }),
/* 19 */
/***/ (function(module, exports) {

	/** @license React v16.12.0
	 * react-is.production.min.js
	 *
	 * Copyright (c) Facebook, Inc. and its affiliates.
	 *
	 * This source code is licensed under the MIT license found in the
	 * LICENSE file in the root directory of this source tree.
	 */
	
	'use strict';Object.defineProperty(exports,"__esModule",{value:!0});
	var b="function"===typeof Symbol&&Symbol.for,c=b?Symbol.for("react.element"):60103,d=b?Symbol.for("react.portal"):60106,e=b?Symbol.for("react.fragment"):60107,f=b?Symbol.for("react.strict_mode"):60108,g=b?Symbol.for("react.profiler"):60114,h=b?Symbol.for("react.provider"):60109,k=b?Symbol.for("react.context"):60110,l=b?Symbol.for("react.async_mode"):60111,m=b?Symbol.for("react.concurrent_mode"):60111,n=b?Symbol.for("react.forward_ref"):60112,p=b?Symbol.for("react.suspense"):60113,q=b?Symbol.for("react.suspense_list"):
	60120,r=b?Symbol.for("react.memo"):60115,t=b?Symbol.for("react.lazy"):60116,v=b?Symbol.for("react.fundamental"):60117,w=b?Symbol.for("react.responder"):60118,x=b?Symbol.for("react.scope"):60119;function y(a){if("object"===typeof a&&null!==a){var u=a.$$typeof;switch(u){case c:switch(a=a.type,a){case l:case m:case e:case g:case f:case p:return a;default:switch(a=a&&a.$$typeof,a){case k:case n:case t:case r:case h:return a;default:return u}}case d:return u}}}function z(a){return y(a)===m}
	exports.typeOf=y;exports.AsyncMode=l;exports.ConcurrentMode=m;exports.ContextConsumer=k;exports.ContextProvider=h;exports.Element=c;exports.ForwardRef=n;exports.Fragment=e;exports.Lazy=t;exports.Memo=r;exports.Portal=d;exports.Profiler=g;exports.StrictMode=f;exports.Suspense=p;
	exports.isValidElementType=function(a){return"string"===typeof a||"function"===typeof a||a===e||a===m||a===g||a===f||a===p||a===q||"object"===typeof a&&null!==a&&(a.$$typeof===t||a.$$typeof===r||a.$$typeof===h||a.$$typeof===k||a.$$typeof===n||a.$$typeof===v||a.$$typeof===w||a.$$typeof===x)};exports.isAsyncMode=function(a){return z(a)||y(a)===l};exports.isConcurrentMode=z;exports.isContextConsumer=function(a){return y(a)===k};exports.isContextProvider=function(a){return y(a)===h};
	exports.isElement=function(a){return"object"===typeof a&&null!==a&&a.$$typeof===c};exports.isForwardRef=function(a){return y(a)===n};exports.isFragment=function(a){return y(a)===e};exports.isLazy=function(a){return y(a)===t};exports.isMemo=function(a){return y(a)===r};exports.isPortal=function(a){return y(a)===d};exports.isProfiler=function(a){return y(a)===g};exports.isStrictMode=function(a){return y(a)===f};exports.isSuspense=function(a){return y(a)===p};


/***/ }),
/* 20 */
/***/ (function(module, exports, __webpack_require__) {

	/* WEBPACK VAR INJECTION */(function(process) {/** @license React v16.12.0
	 * react-is.development.js
	 *
	 * Copyright (c) Facebook, Inc. and its affiliates.
	 *
	 * This source code is licensed under the MIT license found in the
	 * LICENSE file in the root directory of this source tree.
	 */
	
	'use strict';
	
	
	
	if (process.env.NODE_ENV !== "production") {
	  (function() {
	'use strict';
	
	Object.defineProperty(exports, '__esModule', { value: true });
	
	// The Symbol used to tag the ReactElement-like types. If there is no native Symbol
	// nor polyfill, then a plain number is used for performance.
	var hasSymbol = typeof Symbol === 'function' && Symbol.for;
	var REACT_ELEMENT_TYPE = hasSymbol ? Symbol.for('react.element') : 0xeac7;
	var REACT_PORTAL_TYPE = hasSymbol ? Symbol.for('react.portal') : 0xeaca;
	var REACT_FRAGMENT_TYPE = hasSymbol ? Symbol.for('react.fragment') : 0xeacb;
	var REACT_STRICT_MODE_TYPE = hasSymbol ? Symbol.for('react.strict_mode') : 0xeacc;
	var REACT_PROFILER_TYPE = hasSymbol ? Symbol.for('react.profiler') : 0xead2;
	var REACT_PROVIDER_TYPE = hasSymbol ? Symbol.for('react.provider') : 0xeacd;
	var REACT_CONTEXT_TYPE = hasSymbol ? Symbol.for('react.context') : 0xeace; // TODO: We don't use AsyncMode or ConcurrentMode anymore. They were temporary
	// (unstable) APIs that have been removed. Can we remove the symbols?
	
	var REACT_ASYNC_MODE_TYPE = hasSymbol ? Symbol.for('react.async_mode') : 0xeacf;
	var REACT_CONCURRENT_MODE_TYPE = hasSymbol ? Symbol.for('react.concurrent_mode') : 0xeacf;
	var REACT_FORWARD_REF_TYPE = hasSymbol ? Symbol.for('react.forward_ref') : 0xead0;
	var REACT_SUSPENSE_TYPE = hasSymbol ? Symbol.for('react.suspense') : 0xead1;
	var REACT_SUSPENSE_LIST_TYPE = hasSymbol ? Symbol.for('react.suspense_list') : 0xead8;
	var REACT_MEMO_TYPE = hasSymbol ? Symbol.for('react.memo') : 0xead3;
	var REACT_LAZY_TYPE = hasSymbol ? Symbol.for('react.lazy') : 0xead4;
	var REACT_FUNDAMENTAL_TYPE = hasSymbol ? Symbol.for('react.fundamental') : 0xead5;
	var REACT_RESPONDER_TYPE = hasSymbol ? Symbol.for('react.responder') : 0xead6;
	var REACT_SCOPE_TYPE = hasSymbol ? Symbol.for('react.scope') : 0xead7;
	
	function isValidElementType(type) {
	  return typeof type === 'string' || typeof type === 'function' || // Note: its typeof might be other than 'symbol' or 'number' if it's a polyfill.
	  type === REACT_FRAGMENT_TYPE || type === REACT_CONCURRENT_MODE_TYPE || type === REACT_PROFILER_TYPE || type === REACT_STRICT_MODE_TYPE || type === REACT_SUSPENSE_TYPE || type === REACT_SUSPENSE_LIST_TYPE || typeof type === 'object' && type !== null && (type.$$typeof === REACT_LAZY_TYPE || type.$$typeof === REACT_MEMO_TYPE || type.$$typeof === REACT_PROVIDER_TYPE || type.$$typeof === REACT_CONTEXT_TYPE || type.$$typeof === REACT_FORWARD_REF_TYPE || type.$$typeof === REACT_FUNDAMENTAL_TYPE || type.$$typeof === REACT_RESPONDER_TYPE || type.$$typeof === REACT_SCOPE_TYPE);
	}
	
	/**
	 * Forked from fbjs/warning:
	 * https://github.com/facebook/fbjs/blob/e66ba20ad5be433eb54423f2b097d829324d9de6/packages/fbjs/src/__forks__/warning.js
	 *
	 * Only change is we use console.warn instead of console.error,
	 * and do nothing when 'console' is not supported.
	 * This really simplifies the code.
	 * ---
	 * Similar to invariant but only logs a warning if the condition is not met.
	 * This can be used to log issues in development environments in critical
	 * paths. Removing the logging code for production environments will keep the
	 * same logic and follow the same code paths.
	 */
	var lowPriorityWarningWithoutStack = function () {};
	
	{
	  var printWarning = function (format) {
	    for (var _len = arguments.length, args = new Array(_len > 1 ? _len - 1 : 0), _key = 1; _key < _len; _key++) {
	      args[_key - 1] = arguments[_key];
	    }
	
	    var argIndex = 0;
	    var message = 'Warning: ' + format.replace(/%s/g, function () {
	      return args[argIndex++];
	    });
	
	    if (typeof console !== 'undefined') {
	      console.warn(message);
	    }
	
	    try {
	      // --- Welcome to debugging React ---
	      // This error was thrown as a convenience so that you can use this stack
	      // to find the callsite that caused this warning to fire.
	      throw new Error(message);
	    } catch (x) {}
	  };
	
	  lowPriorityWarningWithoutStack = function (condition, format) {
	    if (format === undefined) {
	      throw new Error('`lowPriorityWarningWithoutStack(condition, format, ...args)` requires a warning ' + 'message argument');
	    }
	
	    if (!condition) {
	      for (var _len2 = arguments.length, args = new Array(_len2 > 2 ? _len2 - 2 : 0), _key2 = 2; _key2 < _len2; _key2++) {
	        args[_key2 - 2] = arguments[_key2];
	      }
	
	      printWarning.apply(void 0, [format].concat(args));
	    }
	  };
	}
	
	var lowPriorityWarningWithoutStack$1 = lowPriorityWarningWithoutStack;
	
	function typeOf(object) {
	  if (typeof object === 'object' && object !== null) {
	    var $$typeof = object.$$typeof;
	
	    switch ($$typeof) {
	      case REACT_ELEMENT_TYPE:
	        var type = object.type;
	
	        switch (type) {
	          case REACT_ASYNC_MODE_TYPE:
	          case REACT_CONCURRENT_MODE_TYPE:
	          case REACT_FRAGMENT_TYPE:
	          case REACT_PROFILER_TYPE:
	          case REACT_STRICT_MODE_TYPE:
	          case REACT_SUSPENSE_TYPE:
	            return type;
	
	          default:
	            var $$typeofType = type && type.$$typeof;
	
	            switch ($$typeofType) {
	              case REACT_CONTEXT_TYPE:
	              case REACT_FORWARD_REF_TYPE:
	              case REACT_LAZY_TYPE:
	              case REACT_MEMO_TYPE:
	              case REACT_PROVIDER_TYPE:
	                return $$typeofType;
	
	              default:
	                return $$typeof;
	            }
	
	        }
	
	      case REACT_PORTAL_TYPE:
	        return $$typeof;
	    }
	  }
	
	  return undefined;
	} // AsyncMode is deprecated along with isAsyncMode
	
	var AsyncMode = REACT_ASYNC_MODE_TYPE;
	var ConcurrentMode = REACT_CONCURRENT_MODE_TYPE;
	var ContextConsumer = REACT_CONTEXT_TYPE;
	var ContextProvider = REACT_PROVIDER_TYPE;
	var Element = REACT_ELEMENT_TYPE;
	var ForwardRef = REACT_FORWARD_REF_TYPE;
	var Fragment = REACT_FRAGMENT_TYPE;
	var Lazy = REACT_LAZY_TYPE;
	var Memo = REACT_MEMO_TYPE;
	var Portal = REACT_PORTAL_TYPE;
	var Profiler = REACT_PROFILER_TYPE;
	var StrictMode = REACT_STRICT_MODE_TYPE;
	var Suspense = REACT_SUSPENSE_TYPE;
	var hasWarnedAboutDeprecatedIsAsyncMode = false; // AsyncMode should be deprecated
	
	function isAsyncMode(object) {
	  {
	    if (!hasWarnedAboutDeprecatedIsAsyncMode) {
	      hasWarnedAboutDeprecatedIsAsyncMode = true;
	      lowPriorityWarningWithoutStack$1(false, 'The ReactIs.isAsyncMode() alias has been deprecated, ' + 'and will be removed in React 17+. Update your code to use ' + 'ReactIs.isConcurrentMode() instead. It has the exact same API.');
	    }
	  }
	
	  return isConcurrentMode(object) || typeOf(object) === REACT_ASYNC_MODE_TYPE;
	}
	function isConcurrentMode(object) {
	  return typeOf(object) === REACT_CONCURRENT_MODE_TYPE;
	}
	function isContextConsumer(object) {
	  return typeOf(object) === REACT_CONTEXT_TYPE;
	}
	function isContextProvider(object) {
	  return typeOf(object) === REACT_PROVIDER_TYPE;
	}
	function isElement(object) {
	  return typeof object === 'object' && object !== null && object.$$typeof === REACT_ELEMENT_TYPE;
	}
	function isForwardRef(object) {
	  return typeOf(object) === REACT_FORWARD_REF_TYPE;
	}
	function isFragment(object) {
	  return typeOf(object) === REACT_FRAGMENT_TYPE;
	}
	function isLazy(object) {
	  return typeOf(object) === REACT_LAZY_TYPE;
	}
	function isMemo(object) {
	  return typeOf(object) === REACT_MEMO_TYPE;
	}
	function isPortal(object) {
	  return typeOf(object) === REACT_PORTAL_TYPE;
	}
	function isProfiler(object) {
	  return typeOf(object) === REACT_PROFILER_TYPE;
	}
	function isStrictMode(object) {
	  return typeOf(object) === REACT_STRICT_MODE_TYPE;
	}
	function isSuspense(object) {
	  return typeOf(object) === REACT_SUSPENSE_TYPE;
	}
	
	exports.typeOf = typeOf;
	exports.AsyncMode = AsyncMode;
	exports.ConcurrentMode = ConcurrentMode;
	exports.ContextConsumer = ContextConsumer;
	exports.ContextProvider = ContextProvider;
	exports.Element = Element;
	exports.ForwardRef = ForwardRef;
	exports.Fragment = Fragment;
	exports.Lazy = Lazy;
	exports.Memo = Memo;
	exports.Portal = Portal;
	exports.Profiler = Profiler;
	exports.StrictMode = StrictMode;
	exports.Suspense = Suspense;
	exports.isValidElementType = isValidElementType;
	exports.isAsyncMode = isAsyncMode;
	exports.isConcurrentMode = isConcurrentMode;
	exports.isContextConsumer = isContextConsumer;
	exports.isContextProvider = isContextProvider;
	exports.isElement = isElement;
	exports.isForwardRef = isForwardRef;
	exports.isFragment = isFragment;
	exports.isLazy = isLazy;
	exports.isMemo = isMemo;
	exports.isPortal = isPortal;
	exports.isProfiler = isProfiler;
	exports.isStrictMode = isStrictMode;
	exports.isSuspense = isSuspense;
	  })();
	}
	
	/* WEBPACK VAR INJECTION */}.call(exports, __webpack_require__(11)))

/***/ }),
/* 21 */
/***/ (function(module, exports, __webpack_require__) {

	/* WEBPACK VAR INJECTION */(function(process) {/**
	 * Copyright (c) 2013-present, Facebook, Inc.
	 *
	 * This source code is licensed under the MIT license found in the
	 * LICENSE file in the root directory of this source tree.
	 */
	
	'use strict';
	
	var ReactIs = __webpack_require__(18);
	var assign = __webpack_require__(12);
	
	var ReactPropTypesSecret = __webpack_require__(22);
	var checkPropTypes = __webpack_require__(23);
	
	var has = Function.call.bind(Object.prototype.hasOwnProperty);
	var printWarning = function() {};
	
	if (process.env.NODE_ENV !== 'production') {
	  printWarning = function(text) {
	    var message = 'Warning: ' + text;
	    if (typeof console !== 'undefined') {
	      console.error(message);
	    }
	    try {
	      // --- Welcome to debugging React ---
	      // This error was thrown as a convenience so that you can use this stack
	      // to find the callsite that caused this warning to fire.
	      throw new Error(message);
	    } catch (x) {}
	  };
	}
	
	function emptyFunctionThatReturnsNull() {
	  return null;
	}
	
	module.exports = function(isValidElement, throwOnDirectAccess) {
	  /* global Symbol */
	  var ITERATOR_SYMBOL = typeof Symbol === 'function' && Symbol.iterator;
	  var FAUX_ITERATOR_SYMBOL = '@@iterator'; // Before Symbol spec.
	
	  /**
	   * Returns the iterator method function contained on the iterable object.
	   *
	   * Be sure to invoke the function with the iterable as context:
	   *
	   *     var iteratorFn = getIteratorFn(myIterable);
	   *     if (iteratorFn) {
	   *       var iterator = iteratorFn.call(myIterable);
	   *       ...
	   *     }
	   *
	   * @param {?object} maybeIterable
	   * @return {?function}
	   */
	  function getIteratorFn(maybeIterable) {
	    var iteratorFn = maybeIterable && (ITERATOR_SYMBOL && maybeIterable[ITERATOR_SYMBOL] || maybeIterable[FAUX_ITERATOR_SYMBOL]);
	    if (typeof iteratorFn === 'function') {
	      return iteratorFn;
	    }
	  }
	
	  /**
	   * Collection of methods that allow declaration and validation of props that are
	   * supplied to React components. Example usage:
	   *
	   *   var Props = require('ReactPropTypes');
	   *   var MyArticle = React.createClass({
	   *     propTypes: {
	   *       // An optional string prop named "description".
	   *       description: Props.string,
	   *
	   *       // A required enum prop named "category".
	   *       category: Props.oneOf(['News','Photos']).isRequired,
	   *
	   *       // A prop named "dialog" that requires an instance of Dialog.
	   *       dialog: Props.instanceOf(Dialog).isRequired
	   *     },
	   *     render: function() { ... }
	   *   });
	   *
	   * A more formal specification of how these methods are used:
	   *
	   *   type := array|bool|func|object|number|string|oneOf([...])|instanceOf(...)
	   *   decl := ReactPropTypes.{type}(.isRequired)?
	   *
	   * Each and every declaration produces a function with the same signature. This
	   * allows the creation of custom validation functions. For example:
	   *
	   *  var MyLink = React.createClass({
	   *    propTypes: {
	   *      // An optional string or URI prop named "href".
	   *      href: function(props, propName, componentName) {
	   *        var propValue = props[propName];
	   *        if (propValue != null && typeof propValue !== 'string' &&
	   *            !(propValue instanceof URI)) {
	   *          return new Error(
	   *            'Expected a string or an URI for ' + propName + ' in ' +
	   *            componentName
	   *          );
	   *        }
	   *      }
	   *    },
	   *    render: function() {...}
	   *  });
	   *
	   * @internal
	   */
	
	  var ANONYMOUS = '<<anonymous>>';
	
	  // Important!
	  // Keep this list in sync with production version in `./factoryWithThrowingShims.js`.
	  var ReactPropTypes = {
	    array: createPrimitiveTypeChecker('array'),
	    bool: createPrimitiveTypeChecker('boolean'),
	    func: createPrimitiveTypeChecker('function'),
	    number: createPrimitiveTypeChecker('number'),
	    object: createPrimitiveTypeChecker('object'),
	    string: createPrimitiveTypeChecker('string'),
	    symbol: createPrimitiveTypeChecker('symbol'),
	
	    any: createAnyTypeChecker(),
	    arrayOf: createArrayOfTypeChecker,
	    element: createElementTypeChecker(),
	    elementType: createElementTypeTypeChecker(),
	    instanceOf: createInstanceTypeChecker,
	    node: createNodeChecker(),
	    objectOf: createObjectOfTypeChecker,
	    oneOf: createEnumTypeChecker,
	    oneOfType: createUnionTypeChecker,
	    shape: createShapeTypeChecker,
	    exact: createStrictShapeTypeChecker,
	  };
	
	  /**
	   * inlined Object.is polyfill to avoid requiring consumers ship their own
	   * https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/is
	   */
	  /*eslint-disable no-self-compare*/
	  function is(x, y) {
	    // SameValue algorithm
	    if (x === y) {
	      // Steps 1-5, 7-10
	      // Steps 6.b-6.e: +0 != -0
	      return x !== 0 || 1 / x === 1 / y;
	    } else {
	      // Step 6.a: NaN == NaN
	      return x !== x && y !== y;
	    }
	  }
	  /*eslint-enable no-self-compare*/
	
	  /**
	   * We use an Error-like object for backward compatibility as people may call
	   * PropTypes directly and inspect their output. However, we don't use real
	   * Errors anymore. We don't inspect their stack anyway, and creating them
	   * is prohibitively expensive if they are created too often, such as what
	   * happens in oneOfType() for any type before the one that matched.
	   */
	  function PropTypeError(message) {
	    this.message = message;
	    this.stack = '';
	  }
	  // Make `instanceof Error` still work for returned errors.
	  PropTypeError.prototype = Error.prototype;
	
	  function createChainableTypeChecker(validate) {
	    if (process.env.NODE_ENV !== 'production') {
	      var manualPropTypeCallCache = {};
	      var manualPropTypeWarningCount = 0;
	    }
	    function checkType(isRequired, props, propName, componentName, location, propFullName, secret) {
	      componentName = componentName || ANONYMOUS;
	      propFullName = propFullName || propName;
	
	      if (secret !== ReactPropTypesSecret) {
	        if (throwOnDirectAccess) {
	          // New behavior only for users of `prop-types` package
	          var err = new Error(
	            'Calling PropTypes validators directly is not supported by the `prop-types` package. ' +
	            'Use `PropTypes.checkPropTypes()` to call them. ' +
	            'Read more at http://fb.me/use-check-prop-types'
	          );
	          err.name = 'Invariant Violation';
	          throw err;
	        } else if (process.env.NODE_ENV !== 'production' && typeof console !== 'undefined') {
	          // Old behavior for people using React.PropTypes
	          var cacheKey = componentName + ':' + propName;
	          if (
	            !manualPropTypeCallCache[cacheKey] &&
	            // Avoid spamming the console because they are often not actionable except for lib authors
	            manualPropTypeWarningCount < 3
	          ) {
	            printWarning(
	              'You are manually calling a React.PropTypes validation ' +
	              'function for the `' + propFullName + '` prop on `' + componentName  + '`. This is deprecated ' +
	              'and will throw in the standalone `prop-types` package. ' +
	              'You may be seeing this warning due to a third-party PropTypes ' +
	              'library. See https://fb.me/react-warning-dont-call-proptypes ' + 'for details.'
	            );
	            manualPropTypeCallCache[cacheKey] = true;
	            manualPropTypeWarningCount++;
	          }
	        }
	      }
	      if (props[propName] == null) {
	        if (isRequired) {
	          if (props[propName] === null) {
	            return new PropTypeError('The ' + location + ' `' + propFullName + '` is marked as required ' + ('in `' + componentName + '`, but its value is `null`.'));
	          }
	          return new PropTypeError('The ' + location + ' `' + propFullName + '` is marked as required in ' + ('`' + componentName + '`, but its value is `undefined`.'));
	        }
	        return null;
	      } else {
	        return validate(props, propName, componentName, location, propFullName);
	      }
	    }
	
	    var chainedCheckType = checkType.bind(null, false);
	    chainedCheckType.isRequired = checkType.bind(null, true);
	
	    return chainedCheckType;
	  }
	
	  function createPrimitiveTypeChecker(expectedType) {
	    function validate(props, propName, componentName, location, propFullName, secret) {
	      var propValue = props[propName];
	      var propType = getPropType(propValue);
	      if (propType !== expectedType) {
	        // `propValue` being instance of, say, date/regexp, pass the 'object'
	        // check, but we can offer a more precise error message here rather than
	        // 'of type `object`'.
	        var preciseType = getPreciseType(propValue);
	
	        return new PropTypeError('Invalid ' + location + ' `' + propFullName + '` of type ' + ('`' + preciseType + '` supplied to `' + componentName + '`, expected ') + ('`' + expectedType + '`.'));
	      }
	      return null;
	    }
	    return createChainableTypeChecker(validate);
	  }
	
	  function createAnyTypeChecker() {
	    return createChainableTypeChecker(emptyFunctionThatReturnsNull);
	  }
	
	  function createArrayOfTypeChecker(typeChecker) {
	    function validate(props, propName, componentName, location, propFullName) {
	      if (typeof typeChecker !== 'function') {
	        return new PropTypeError('Property `' + propFullName + '` of component `' + componentName + '` has invalid PropType notation inside arrayOf.');
	      }
	      var propValue = props[propName];
	      if (!Array.isArray(propValue)) {
	        var propType = getPropType(propValue);
	        return new PropTypeError('Invalid ' + location + ' `' + propFullName + '` of type ' + ('`' + propType + '` supplied to `' + componentName + '`, expected an array.'));
	      }
	      for (var i = 0; i < propValue.length; i++) {
	        var error = typeChecker(propValue, i, componentName, location, propFullName + '[' + i + ']', ReactPropTypesSecret);
	        if (error instanceof Error) {
	          return error;
	        }
	      }
	      return null;
	    }
	    return createChainableTypeChecker(validate);
	  }
	
	  function createElementTypeChecker() {
	    function validate(props, propName, componentName, location, propFullName) {
	      var propValue = props[propName];
	      if (!isValidElement(propValue)) {
	        var propType = getPropType(propValue);
	        return new PropTypeError('Invalid ' + location + ' `' + propFullName + '` of type ' + ('`' + propType + '` supplied to `' + componentName + '`, expected a single ReactElement.'));
	      }
	      return null;
	    }
	    return createChainableTypeChecker(validate);
	  }
	
	  function createElementTypeTypeChecker() {
	    function validate(props, propName, componentName, location, propFullName) {
	      var propValue = props[propName];
	      if (!ReactIs.isValidElementType(propValue)) {
	        var propType = getPropType(propValue);
	        return new PropTypeError('Invalid ' + location + ' `' + propFullName + '` of type ' + ('`' + propType + '` supplied to `' + componentName + '`, expected a single ReactElement type.'));
	      }
	      return null;
	    }
	    return createChainableTypeChecker(validate);
	  }
	
	  function createInstanceTypeChecker(expectedClass) {
	    function validate(props, propName, componentName, location, propFullName) {
	      if (!(props[propName] instanceof expectedClass)) {
	        var expectedClassName = expectedClass.name || ANONYMOUS;
	        var actualClassName = getClassName(props[propName]);
	        return new PropTypeError('Invalid ' + location + ' `' + propFullName + '` of type ' + ('`' + actualClassName + '` supplied to `' + componentName + '`, expected ') + ('instance of `' + expectedClassName + '`.'));
	      }
	      return null;
	    }
	    return createChainableTypeChecker(validate);
	  }
	
	  function createEnumTypeChecker(expectedValues) {
	    if (!Array.isArray(expectedValues)) {
	      if (process.env.NODE_ENV !== 'production') {
	        if (arguments.length > 1) {
	          printWarning(
	            'Invalid arguments supplied to oneOf, expected an array, got ' + arguments.length + ' arguments. ' +
	            'A common mistake is to write oneOf(x, y, z) instead of oneOf([x, y, z]).'
	          );
	        } else {
	          printWarning('Invalid argument supplied to oneOf, expected an array.');
	        }
	      }
	      return emptyFunctionThatReturnsNull;
	    }
	
	    function validate(props, propName, componentName, location, propFullName) {
	      var propValue = props[propName];
	      for (var i = 0; i < expectedValues.length; i++) {
	        if (is(propValue, expectedValues[i])) {
	          return null;
	        }
	      }
	
	      var valuesString = JSON.stringify(expectedValues, function replacer(key, value) {
	        var type = getPreciseType(value);
	        if (type === 'symbol') {
	          return String(value);
	        }
	        return value;
	      });
	      return new PropTypeError('Invalid ' + location + ' `' + propFullName + '` of value `' + String(propValue) + '` ' + ('supplied to `' + componentName + '`, expected one of ' + valuesString + '.'));
	    }
	    return createChainableTypeChecker(validate);
	  }
	
	  function createObjectOfTypeChecker(typeChecker) {
	    function validate(props, propName, componentName, location, propFullName) {
	      if (typeof typeChecker !== 'function') {
	        return new PropTypeError('Property `' + propFullName + '` of component `' + componentName + '` has invalid PropType notation inside objectOf.');
	      }
	      var propValue = props[propName];
	      var propType = getPropType(propValue);
	      if (propType !== 'object') {
	        return new PropTypeError('Invalid ' + location + ' `' + propFullName + '` of type ' + ('`' + propType + '` supplied to `' + componentName + '`, expected an object.'));
	      }
	      for (var key in propValue) {
	        if (has(propValue, key)) {
	          var error = typeChecker(propValue, key, componentName, location, propFullName + '.' + key, ReactPropTypesSecret);
	          if (error instanceof Error) {
	            return error;
	          }
	        }
	      }
	      return null;
	    }
	    return createChainableTypeChecker(validate);
	  }
	
	  function createUnionTypeChecker(arrayOfTypeCheckers) {
	    if (!Array.isArray(arrayOfTypeCheckers)) {
	      process.env.NODE_ENV !== 'production' ? printWarning('Invalid argument supplied to oneOfType, expected an instance of array.') : void 0;
	      return emptyFunctionThatReturnsNull;
	    }
	
	    for (var i = 0; i < arrayOfTypeCheckers.length; i++) {
	      var checker = arrayOfTypeCheckers[i];
	      if (typeof checker !== 'function') {
	        printWarning(
	          'Invalid argument supplied to oneOfType. Expected an array of check functions, but ' +
	          'received ' + getPostfixForTypeWarning(checker) + ' at index ' + i + '.'
	        );
	        return emptyFunctionThatReturnsNull;
	      }
	    }
	
	    function validate(props, propName, componentName, location, propFullName) {
	      for (var i = 0; i < arrayOfTypeCheckers.length; i++) {
	        var checker = arrayOfTypeCheckers[i];
	        if (checker(props, propName, componentName, location, propFullName, ReactPropTypesSecret) == null) {
	          return null;
	        }
	      }
	
	      return new PropTypeError('Invalid ' + location + ' `' + propFullName + '` supplied to ' + ('`' + componentName + '`.'));
	    }
	    return createChainableTypeChecker(validate);
	  }
	
	  function createNodeChecker() {
	    function validate(props, propName, componentName, location, propFullName) {
	      if (!isNode(props[propName])) {
	        return new PropTypeError('Invalid ' + location + ' `' + propFullName + '` supplied to ' + ('`' + componentName + '`, expected a ReactNode.'));
	      }
	      return null;
	    }
	    return createChainableTypeChecker(validate);
	  }
	
	  function createShapeTypeChecker(shapeTypes) {
	    function validate(props, propName, componentName, location, propFullName) {
	      var propValue = props[propName];
	      var propType = getPropType(propValue);
	      if (propType !== 'object') {
	        return new PropTypeError('Invalid ' + location + ' `' + propFullName + '` of type `' + propType + '` ' + ('supplied to `' + componentName + '`, expected `object`.'));
	      }
	      for (var key in shapeTypes) {
	        var checker = shapeTypes[key];
	        if (!checker) {
	          continue;
	        }
	        var error = checker(propValue, key, componentName, location, propFullName + '.' + key, ReactPropTypesSecret);
	        if (error) {
	          return error;
	        }
	      }
	      return null;
	    }
	    return createChainableTypeChecker(validate);
	  }
	
	  function createStrictShapeTypeChecker(shapeTypes) {
	    function validate(props, propName, componentName, location, propFullName) {
	      var propValue = props[propName];
	      var propType = getPropType(propValue);
	      if (propType !== 'object') {
	        return new PropTypeError('Invalid ' + location + ' `' + propFullName + '` of type `' + propType + '` ' + ('supplied to `' + componentName + '`, expected `object`.'));
	      }
	      // We need to check all keys in case some are required but missing from
	      // props.
	      var allKeys = assign({}, props[propName], shapeTypes);
	      for (var key in allKeys) {
	        var checker = shapeTypes[key];
	        if (!checker) {
	          return new PropTypeError(
	            'Invalid ' + location + ' `' + propFullName + '` key `' + key + '` supplied to `' + componentName + '`.' +
	            '\nBad object: ' + JSON.stringify(props[propName], null, '  ') +
	            '\nValid keys: ' +  JSON.stringify(Object.keys(shapeTypes), null, '  ')
	          );
	        }
	        var error = checker(propValue, key, componentName, location, propFullName + '.' + key, ReactPropTypesSecret);
	        if (error) {
	          return error;
	        }
	      }
	      return null;
	    }
	
	    return createChainableTypeChecker(validate);
	  }
	
	  function isNode(propValue) {
	    switch (typeof propValue) {
	      case 'number':
	      case 'string':
	      case 'undefined':
	        return true;
	      case 'boolean':
	        return !propValue;
	      case 'object':
	        if (Array.isArray(propValue)) {
	          return propValue.every(isNode);
	        }
	        if (propValue === null || isValidElement(propValue)) {
	          return true;
	        }
	
	        var iteratorFn = getIteratorFn(propValue);
	        if (iteratorFn) {
	          var iterator = iteratorFn.call(propValue);
	          var step;
	          if (iteratorFn !== propValue.entries) {
	            while (!(step = iterator.next()).done) {
	              if (!isNode(step.value)) {
	                return false;
	              }
	            }
	          } else {
	            // Iterator will provide entry [k,v] tuples rather than values.
	            while (!(step = iterator.next()).done) {
	              var entry = step.value;
	              if (entry) {
	                if (!isNode(entry[1])) {
	                  return false;
	                }
	              }
	            }
	          }
	        } else {
	          return false;
	        }
	
	        return true;
	      default:
	        return false;
	    }
	  }
	
	  function isSymbol(propType, propValue) {
	    // Native Symbol.
	    if (propType === 'symbol') {
	      return true;
	    }
	
	    // falsy value can't be a Symbol
	    if (!propValue) {
	      return false;
	    }
	
	    // 19.4.3.5 Symbol.prototype[@@toStringTag] === 'Symbol'
	    if (propValue['@@toStringTag'] === 'Symbol') {
	      return true;
	    }
	
	    // Fallback for non-spec compliant Symbols which are polyfilled.
	    if (typeof Symbol === 'function' && propValue instanceof Symbol) {
	      return true;
	    }
	
	    return false;
	  }
	
	  // Equivalent of `typeof` but with special handling for array and regexp.
	  function getPropType(propValue) {
	    var propType = typeof propValue;
	    if (Array.isArray(propValue)) {
	      return 'array';
	    }
	    if (propValue instanceof RegExp) {
	      // Old webkits (at least until Android 4.0) return 'function' rather than
	      // 'object' for typeof a RegExp. We'll normalize this here so that /bla/
	      // passes PropTypes.object.
	      return 'object';
	    }
	    if (isSymbol(propType, propValue)) {
	      return 'symbol';
	    }
	    return propType;
	  }
	
	  // This handles more types than `getPropType`. Only used for error messages.
	  // See `createPrimitiveTypeChecker`.
	  function getPreciseType(propValue) {
	    if (typeof propValue === 'undefined' || propValue === null) {
	      return '' + propValue;
	    }
	    var propType = getPropType(propValue);
	    if (propType === 'object') {
	      if (propValue instanceof Date) {
	        return 'date';
	      } else if (propValue instanceof RegExp) {
	        return 'regexp';
	      }
	    }
	    return propType;
	  }
	
	  // Returns a string that is postfixed to a warning about an invalid type.
	  // For example, "undefined" or "of type array"
	  function getPostfixForTypeWarning(value) {
	    var type = getPreciseType(value);
	    switch (type) {
	      case 'array':
	      case 'object':
	        return 'an ' + type;
	      case 'boolean':
	      case 'date':
	      case 'regexp':
	        return 'a ' + type;
	      default:
	        return type;
	    }
	  }
	
	  // Returns class name of the object, if any.
	  function getClassName(propValue) {
	    if (!propValue.constructor || !propValue.constructor.name) {
	      return ANONYMOUS;
	    }
	    return propValue.constructor.name;
	  }
	
	  ReactPropTypes.checkPropTypes = checkPropTypes;
	  ReactPropTypes.resetWarningCache = checkPropTypes.resetWarningCache;
	  ReactPropTypes.PropTypes = ReactPropTypes;
	
	  return ReactPropTypes;
	};
	
	/* WEBPACK VAR INJECTION */}.call(exports, __webpack_require__(11)))

/***/ }),
/* 22 */
/***/ (function(module, exports) {

	/**
	 * Copyright (c) 2013-present, Facebook, Inc.
	 *
	 * This source code is licensed under the MIT license found in the
	 * LICENSE file in the root directory of this source tree.
	 */
	
	'use strict';
	
	var ReactPropTypesSecret = 'SECRET_DO_NOT_PASS_THIS_OR_YOU_WILL_BE_FIRED';
	
	module.exports = ReactPropTypesSecret;


/***/ }),
/* 23 */
/***/ (function(module, exports, __webpack_require__) {

	/* WEBPACK VAR INJECTION */(function(process) {/**
	 * Copyright (c) 2013-present, Facebook, Inc.
	 *
	 * This source code is licensed under the MIT license found in the
	 * LICENSE file in the root directory of this source tree.
	 */
	
	'use strict';
	
	var printWarning = function() {};
	
	if (process.env.NODE_ENV !== 'production') {
	  var ReactPropTypesSecret = __webpack_require__(22);
	  var loggedTypeFailures = {};
	  var has = Function.call.bind(Object.prototype.hasOwnProperty);
	
	  printWarning = function(text) {
	    var message = 'Warning: ' + text;
	    if (typeof console !== 'undefined') {
	      console.error(message);
	    }
	    try {
	      // --- Welcome to debugging React ---
	      // This error was thrown as a convenience so that you can use this stack
	      // to find the callsite that caused this warning to fire.
	      throw new Error(message);
	    } catch (x) {}
	  };
	}
	
	/**
	 * Assert that the values match with the type specs.
	 * Error messages are memorized and will only be shown once.
	 *
	 * @param {object} typeSpecs Map of name to a ReactPropType
	 * @param {object} values Runtime values that need to be type-checked
	 * @param {string} location e.g. "prop", "context", "child context"
	 * @param {string} componentName Name of the component for error messages.
	 * @param {?Function} getStack Returns the component stack.
	 * @private
	 */
	function checkPropTypes(typeSpecs, values, location, componentName, getStack) {
	  if (process.env.NODE_ENV !== 'production') {
	    for (var typeSpecName in typeSpecs) {
	      if (has(typeSpecs, typeSpecName)) {
	        var error;
	        // Prop type validation may throw. In case they do, we don't want to
	        // fail the render phase where it didn't fail before. So we log it.
	        // After these have been cleaned up, we'll let them throw.
	        try {
	          // This is intentionally an invariant that gets caught. It's the same
	          // behavior as without this statement except with a better message.
	          if (typeof typeSpecs[typeSpecName] !== 'function') {
	            var err = Error(
	              (componentName || 'React class') + ': ' + location + ' type `' + typeSpecName + '` is invalid; ' +
	              'it must be a function, usually from the `prop-types` package, but received `' + typeof typeSpecs[typeSpecName] + '`.'
	            );
	            err.name = 'Invariant Violation';
	            throw err;
	          }
	          error = typeSpecs[typeSpecName](values, typeSpecName, componentName, location, null, ReactPropTypesSecret);
	        } catch (ex) {
	          error = ex;
	        }
	        if (error && !(error instanceof Error)) {
	          printWarning(
	            (componentName || 'React class') + ': type specification of ' +
	            location + ' `' + typeSpecName + '` is invalid; the type checker ' +
	            'function must return `null` or an `Error` but returned a ' + typeof error + '. ' +
	            'You may have forgotten to pass an argument to the type checker ' +
	            'creator (arrayOf, instanceOf, objectOf, oneOf, oneOfType, and ' +
	            'shape all require an argument).'
	          );
	        }
	        if (error instanceof Error && !(error.message in loggedTypeFailures)) {
	          // Only monitor this failure once because there tends to be a lot of the
	          // same error.
	          loggedTypeFailures[error.message] = true;
	
	          var stack = getStack ? getStack() : '';
	
	          printWarning(
	            'Failed ' + location + ' type: ' + error.message + (stack != null ? stack : '')
	          );
	        }
	      }
	    }
	  }
	}
	
	/**
	 * Resets warning cache when testing.
	 *
	 * @private
	 */
	checkPropTypes.resetWarningCache = function() {
	  if (process.env.NODE_ENV !== 'production') {
	    loggedTypeFailures = {};
	  }
	}
	
	module.exports = checkPropTypes;
	
	/* WEBPACK VAR INJECTION */}.call(exports, __webpack_require__(11)))

/***/ }),
/* 24 */
/***/ (function(module, exports, __webpack_require__) {

	/**
	 * Copyright (c) 2013-present, Facebook, Inc.
	 *
	 * This source code is licensed under the MIT license found in the
	 * LICENSE file in the root directory of this source tree.
	 */
	
	'use strict';
	
	var ReactPropTypesSecret = __webpack_require__(22);
	
	function emptyFunction() {}
	function emptyFunctionWithReset() {}
	emptyFunctionWithReset.resetWarningCache = emptyFunction;
	
	module.exports = function() {
	  function shim(props, propName, componentName, location, propFullName, secret) {
	    if (secret === ReactPropTypesSecret) {
	      // It is still safe when called from React.
	      return;
	    }
	    var err = new Error(
	      'Calling PropTypes validators directly is not supported by the `prop-types` package. ' +
	      'Use PropTypes.checkPropTypes() to call them. ' +
	      'Read more at http://fb.me/use-check-prop-types'
	    );
	    err.name = 'Invariant Violation';
	    throw err;
	  };
	  shim.isRequired = shim;
	  function getShim() {
	    return shim;
	  };
	  // Important!
	  // Keep this list in sync with production version in `./factoryWithTypeCheckers.js`.
	  var ReactPropTypes = {
	    array: shim,
	    bool: shim,
	    func: shim,
	    number: shim,
	    object: shim,
	    string: shim,
	    symbol: shim,
	
	    any: shim,
	    arrayOf: getShim,
	    element: shim,
	    elementType: shim,
	    instanceOf: getShim,
	    node: shim,
	    objectOf: getShim,
	    oneOf: getShim,
	    oneOfType: getShim,
	    shape: getShim,
	    exact: getShim,
	
	    checkPropTypes: emptyFunctionWithReset,
	    resetWarningCache: emptyFunction
	  };
	
	  ReactPropTypes.PropTypes = ReactPropTypes;
	
	  return ReactPropTypes;
	};


/***/ }),
/* 25 */
/***/ (function(module, exports) {

	/**
	 * PolyFills make me sad
	 */
	var KeyEvent = KeyEvent || {};
	KeyEvent.DOM_VK_UP = KeyEvent.DOM_VK_UP || 38;
	KeyEvent.DOM_VK_DOWN = KeyEvent.DOM_VK_DOWN || 40;
	KeyEvent.DOM_VK_BACK_SPACE = KeyEvent.DOM_VK_BACK_SPACE || 8;
	KeyEvent.DOM_VK_RETURN = KeyEvent.DOM_VK_RETURN || 13;
	KeyEvent.DOM_VK_ENTER = KeyEvent.DOM_VK_ENTER || 14;
	KeyEvent.DOM_VK_ESCAPE = KeyEvent.DOM_VK_ESCAPE || 27;
	KeyEvent.DOM_VK_TAB = KeyEvent.DOM_VK_TAB || 9;
	
	module.exports = KeyEvent;

/***/ }),
/* 26 */
/***/ (function(module, exports, __webpack_require__) {

	/*
	 * Fuzzy
	 * https://github.com/myork/fuzzy
	 *
	 * Copyright (c) 2012 Matt York
	 * Licensed under the MIT license.
	 */
	
	(function() {
	
	var root = this;
	
	var fuzzy = {};
	
	// Use in node or in browser
	if (true) {
	  module.exports = fuzzy;
	} else {
	  root.fuzzy = fuzzy;
	}
	
	// Return all elements of `array` that have a fuzzy
	// match against `pattern`.
	fuzzy.simpleFilter = function(pattern, array) {
	  return array.filter(function(str) {
	    return fuzzy.test(pattern, str);
	  });
	};
	
	// Does `pattern` fuzzy match `str`?
	fuzzy.test = function(pattern, str) {
	  return fuzzy.match(pattern, str) !== null;
	};
	
	// If `pattern` matches `str`, wrap each matching character
	// in `opts.pre` and `opts.post`. If no match, return null
	fuzzy.match = function(pattern, str, opts) {
	  opts = opts || {};
	  var patternIdx = 0
	    , result = []
	    , len = str.length
	    , totalScore = 0
	    , currScore = 0
	    // prefix
	    , pre = opts.pre || ''
	    // suffix
	    , post = opts.post || ''
	    // String to compare against. This might be a lowercase version of the
	    // raw string
	    , compareString =  opts.caseSensitive && str || str.toLowerCase()
	    , ch;
	
	  pattern = opts.caseSensitive && pattern || pattern.toLowerCase();
	
	  // For each character in the string, either add it to the result
	  // or wrap in template if it's the next string in the pattern
	  for(var idx = 0; idx < len; idx++) {
	    ch = str[idx];
	    if(compareString[idx] === pattern[patternIdx]) {
	      ch = pre + ch + post;
	      patternIdx += 1;
	
	      // consecutive characters should increase the score more than linearly
	      currScore += 1 + currScore;
	    } else {
	      currScore = 0;
	    }
	    totalScore += currScore;
	    result[result.length] = ch;
	  }
	
	  // return rendered string if we have a match for every char
	  if(patternIdx === pattern.length) {
	    // if the string is an exact match with pattern, totalScore should be maxed
	    totalScore = (compareString === pattern) ? Infinity : totalScore;
	    return {rendered: result.join(''), score: totalScore};
	  }
	
	  return null;
	};
	
	// The normal entry point. Filters `arr` for matches against `pattern`.
	// It returns an array with matching values of the type:
	//
	//     [{
	//         string:   '<b>lah' // The rendered string
	//       , index:    2        // The index of the element in `arr`
	//       , original: 'blah'   // The original element in `arr`
	//     }]
	//
	// `opts` is an optional argument bag. Details:
	//
	//    opts = {
	//        // string to put before a matching character
	//        pre:     '<b>'
	//
	//        // string to put after matching character
	//      , post:    '</b>'
	//
	//        // Optional function. Input is an entry in the given arr`,
	//        // output should be the string to test `pattern` against.
	//        // In this example, if `arr = [{crying: 'koala'}]` we would return
	//        // 'koala'.
	//      , extract: function(arg) { return arg.crying; }
	//    }
	fuzzy.filter = function(pattern, arr, opts) {
	  if(!arr || arr.length === 0) {
	    return [];
	  }
	  if (typeof pattern !== 'string') {
	    return arr;
	  }
	  opts = opts || {};
	  return arr
	    .reduce(function(prev, element, idx, arr) {
	      var str = element;
	      if(opts.extract) {
	        str = opts.extract(element);
	      }
	      var rendered = fuzzy.match(pattern, str, opts);
	      if(rendered != null) {
	        prev[prev.length] = {
	            string: rendered.rendered
	          , score: rendered.score
	          , index: idx
	          , original: element
	        };
	      }
	      return prev;
	    }, [])
	
	    // Sort by score. Browsers are inconsistent wrt stable/unstable
	    // sorting, so force stable by using the index in the case of tie.
	    // See http://ofb.net/~sethml/is-sort-stable.html
	    .sort(function(a,b) {
	      var compare = b.score - a.score;
	      if(compare) return compare;
	      return a.index - b.index;
	    });
	};
	
	
	}());
	


/***/ }),
/* 27 */
/***/ (function(module, exports, __webpack_require__) {

	var Accessor = __webpack_require__(5);
	var React = __webpack_require__(1);
	var Token = __webpack_require__(28);
	var KeyEvent = __webpack_require__(25);
	var Typeahead = __webpack_require__(4);
	var classNames = __webpack_require__(8);
	var createReactClass = __webpack_require__(9);
	var PropTypes = __webpack_require__(17);
	
	function _arraysAreDifferent(array1, array2) {
	  if (array1.length != array2.length) {
	    return true;
	  }
	  for (var i = array2.length - 1; i >= 0; i--) {
	    if (array2[i] !== array1[i]) {
	      return true;
	    }
	  }
	}
	
	/**
	 * A typeahead that, when an option is selected, instead of simply filling
	 * the text entry widget, prepends a renderable "token", that may be deleted
	 * by pressing backspace on the beginning of the line with the keyboard.
	 */
	var TypeaheadTokenizer = createReactClass({
	  displayName: 'TypeaheadTokenizer',
	
	  propTypes: {
	    name: PropTypes.string,
	    options: PropTypes.array,
	    customClasses: PropTypes.object,
	    allowCustomValues: PropTypes.number,
	    defaultSelected: PropTypes.array,
	    initialValue: PropTypes.string,
	    placeholder: PropTypes.string,
	    disabled: PropTypes.bool,
	    inputProps: PropTypes.object,
	    onTokenRemove: PropTypes.func,
	    onKeyDown: PropTypes.func,
	    onKeyPress: PropTypes.func,
	    onKeyUp: PropTypes.func,
	    onTokenAdd: PropTypes.func,
	    onFocus: PropTypes.func,
	    onBlur: PropTypes.func,
	    filterOption: PropTypes.oneOfType([PropTypes.string, PropTypes.func]),
	    searchOptions: PropTypes.func,
	    displayOption: PropTypes.oneOfType([PropTypes.string, PropTypes.func]),
	    formInputOption: PropTypes.oneOfType([PropTypes.string, PropTypes.func]),
	    maxVisible: PropTypes.number,
	    resultsTruncatedMessage: PropTypes.string,
	    defaultClassNames: PropTypes.bool,
	    showOptionsWhenEmpty: PropTypes.bool
	  },
	
	  getInitialState: function () {
	    return {
	      // We need to copy this to avoid incorrect sharing
	      // of state across instances (e.g., via getDefaultProps())
	      selected: this.props.defaultSelected.slice(0)
	    };
	  },
	
	  getDefaultProps: function () {
	    return {
	      options: [],
	      defaultSelected: [],
	      customClasses: {},
	      allowCustomValues: 0,
	      initialValue: "",
	      placeholder: "",
	      disabled: false,
	      inputProps: {},
	      defaultClassNames: true,
	      filterOption: null,
	      searchOptions: null,
	      displayOption: function (token) {
	        return token;
	      },
	      formInputOption: null,
	      onKeyDown: function (event) {},
	      onKeyPress: function (event) {},
	      onKeyUp: function (event) {},
	      onFocus: function (event) {},
	      onBlur: function (event) {},
	      onTokenAdd: function () {},
	      onTokenRemove: function () {},
	      showOptionsWhenEmpty: false
	    };
	  },
	
	  componentWillReceiveProps: function (nextProps) {
	    // if we get new defaultProps, update selected
	    if (_arraysAreDifferent(this.props.defaultSelected, nextProps.defaultSelected)) {
	      this.setState({ selected: nextProps.defaultSelected.slice(0) });
	    }
	  },
	
	  focus: function () {
	    this.refs.typeahead.focus();
	  },
	
	  getSelectedTokens: function () {
	    return this.state.selected;
	  },
	
	  // TODO: Support initialized tokens
	  //
	  _renderTokens: function () {
	    var tokenClasses = {};
	    tokenClasses[this.props.customClasses.token] = !!this.props.customClasses.token;
	    var classList = classNames(tokenClasses);
	    var result = this.state.selected.map(function (selected) {
	      var displayString = Accessor.valueForOption(this.props.displayOption, selected);
	      var value = Accessor.valueForOption(this.props.formInputOption || this.props.displayOption, selected);
	      return React.createElement(
	        Token,
	        { key: displayString, className: classList,
	          onRemove: this._removeTokenForValue,
	          object: selected,
	          value: value,
	          name: this.props.name },
	        displayString
	      );
	    }, this);
	    return result;
	  },
	
	  _getOptionsForTypeahead: function () {
	    // return this.props.options without this.selected
	    return this.props.options;
	  },
	
	  _onKeyDown: function (event) {
	    // We only care about intercepting backspaces
	    if (event.keyCode === KeyEvent.DOM_VK_BACK_SPACE) {
	      return this._handleBackspace(event);
	    }
	    this.props.onKeyDown(event);
	  },
	
	  _handleBackspace: function (event) {
	    // No tokens
	    if (!this.state.selected.length) {
	      return;
	    }
	
	    // Remove token ONLY when bksp pressed at beginning of line
	    // without a selection
	    var entry = this.refs.typeahead.refs.entry;
	    if (entry.selectionStart == entry.selectionEnd && entry.selectionStart == 0) {
	      this._removeTokenForValue(this.state.selected[this.state.selected.length - 1]);
	      event.preventDefault();
	    }
	  },
	
	  _removeTokenForValue: function (value) {
	    var index = this.state.selected.indexOf(value);
	    if (index == -1) {
	      return;
	    }
	
	    this.state.selected.splice(index, 1);
	    this.setState({ selected: this.state.selected });
	    this.props.onTokenRemove(value);
	    return;
	  },
	
	  _addTokenForValue: function (value) {
	    if (this.state.selected.indexOf(value) != -1) {
	      return;
	    }
	    this.state.selected.push(value);
	    this.setState({ selected: this.state.selected });
	    this.refs.typeahead.setEntryText("");
	    this.props.onTokenAdd(value);
	  },
	
	  render: function () {
	    var classes = {};
	    classes[this.props.customClasses.typeahead] = !!this.props.customClasses.typeahead;
	    var classList = classNames(classes);
	    var tokenizerClasses = [this.props.defaultClassNames && "typeahead-tokenizer"];
	    tokenizerClasses[this.props.className] = !!this.props.className;
	    var tokenizerClassList = classNames(tokenizerClasses);
	
	    return React.createElement(
	      'div',
	      { className: tokenizerClassList },
	      this._renderTokens(),
	      React.createElement(Typeahead, { ref: 'typeahead',
	        className: classList,
	        placeholder: this.props.placeholder,
	        disabled: this.props.disabled,
	        inputProps: this.props.inputProps,
	        allowCustomValues: this.props.allowCustomValues,
	        customClasses: this.props.customClasses,
	        options: this._getOptionsForTypeahead(),
	        initialValue: this.props.initialValue,
	        maxVisible: this.props.maxVisible,
	        resultsTruncatedMessage: this.props.resultsTruncatedMessage,
	        onOptionSelected: this._addTokenForValue,
	        onKeyDown: this._onKeyDown,
	        onKeyPress: this.props.onKeyPress,
	        onKeyUp: this.props.onKeyUp,
	        onFocus: this.props.onFocus,
	        onBlur: this.props.onBlur,
	        displayOption: this.props.displayOption,
	        defaultClassNames: this.props.defaultClassNames,
	        filterOption: this.props.filterOption,
	        searchOptions: this.props.searchOptions,
	        showOptionsWhenEmpty: this.props.showOptionsWhenEmpty })
	    );
	  }
	});
	
	module.exports = TypeaheadTokenizer;

/***/ }),
/* 28 */
/***/ (function(module, exports, __webpack_require__) {

	var React = __webpack_require__(1);
	var classNames = __webpack_require__(8);
	var createReactClass = __webpack_require__(9);
	var PropTypes = __webpack_require__(17);
	
	/**
	 * Encapsulates the rendering of an option that has been "selected" in a
	 * TypeaheadTokenizer
	 */
	var Token = createReactClass({
	  displayName: 'Token',
	
	  propTypes: {
	    className: PropTypes.string,
	    name: PropTypes.string,
	    children: PropTypes.string,
	    object: PropTypes.oneOfType([PropTypes.string, PropTypes.object]),
	    onRemove: PropTypes.func,
	    value: PropTypes.string
	  },
	
	  render: function () {
	    var className = classNames(["typeahead-token", this.props.className]);
	
	    return React.createElement(
	      'div',
	      { className: className },
	      this._renderHiddenInput(),
	      this.props.children,
	      this._renderCloseButton()
	    );
	  },
	
	  _renderHiddenInput: function () {
	    // If no name was set, don't create a hidden input
	    if (!this.props.name) {
	      return null;
	    }
	
	    return React.createElement('input', {
	      type: 'hidden',
	      name: this.props.name + '[]',
	      value: this.props.value || this.props.object
	    });
	  },
	
	  _renderCloseButton: function () {
	    if (!this.props.onRemove) {
	      return "";
	    }
	    return React.createElement(
	      'a',
	      { className: this.props.className || "typeahead-token-close", href: '#', onClick: function (event) {
	          this.props.onRemove(this.props.object);
	          event.preventDefault();
	        }.bind(this) },
	      '\xD7'
	    );
	  }
	});
	
	module.exports = Token;

/***/ }),
/* 29 */
/***/ (function(module, exports) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	    value: true
	});
	
	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();
	
	function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }
	
	function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }
	
	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
	
	var TYPE_KINDS = exports.TYPE_KINDS = ['SCALAR', 'INTERFACE', 'OBJECT', 'ENUM', 'INPUT_OBJECT', 'UNION'];
	
	var Schema = exports.Schema = function () {
	    function Schema(introspectionResult) {
	        var _this = this;
	
	        _classCallCheck(this, Schema);
	
	        if (!introspectionResult.__schema) {
	            throw new Error('Function  precondition failed: introspectionResult.__schema');
	        }
	
	        if (!Array.isArray(introspectionResult.__schema.types)) {
	            throw new Error('Function  precondition failed: Array.isArray(introspectionResult.__schema.types)');
	        }
	
	        if (!introspectionResult.__schema.queryType) {
	            throw new Error('Function  precondition failed: introspectionResult.__schema.queryType');
	        }
	
	        if (!(introspectionResult.__schema.mutationType === null || typeof introspectionResult.__schema.mutationType.name === 'string')) {
	            throw new Error('Function  precondition failed: introspectionResult.__schema.mutationType === null || typeof introspectionResult.__schema.mutationType.name === \'string\'');
	        }
	
	        this.types = {};
	        introspectionResult.__schema.types.forEach(function (t) {
	            if (!(typeof t.name === 'string')) {
	                throw new Error('Function  precondition failed: typeof t.name === \'string\'');
	            }
	
	            _this.types[t.name] = Type.fromIntrospectionType(t);
	        });
	
	        this.queryTypeId = introspectionResult.__schema.queryType.name;
	
	        if (introspectionResult.__schema.mutationType) {
	            this.mutationTypeId = introspectionResult.__schema.mutationType.name;
	        } else {
	            this.mutationTypeId = null;
	        }
	    }
	
	    _createClass(Schema, [{
	        key: 'getQueryType',
	        value: function getQueryType() {
	            var queryType = this.types[this.queryTypeId];
	
	            if (queryType instanceof ObjectType) {
	                return queryType;
	            } else {
	                throw new Error('Query type must be an ObjectType');
	            }
	        }
	    }, {
	        key: 'getMutationType',
	        value: function getMutationType() {
	            if (!this.mutationTypeId) {
	                return null;
	            }
	
	            var mutationType = this.types[this.mutationTypeId];
	
	            if (mutationType instanceof ObjectType) {
	                return mutationType;
	            } else {
	                throw new Error('Mutation type must be an ObjectType');
	            }
	        }
	    }]);
	
	    return Schema;
	}();
	
	var Type = exports.Type = function () {
	    _createClass(Type, null, [{
	        key: 'fromIntrospectionType',
	        value: function fromIntrospectionType(introspectionType) {
	            if (introspectionType.kind === 'OBJECT') {
	                return new ObjectType(introspectionType);
	            } else if (introspectionType.kind === 'SCALAR') {
	                return new ScalarType(introspectionType);
	            } else if (introspectionType.kind === 'INTERFACE') {
	                return new InterfaceType(introspectionType);
	            } else if (introspectionType.kind === 'ENUM') {
	                return new EnumType(introspectionType);
	            } else if (introspectionType.kind === 'INPUT_OBJECT') {
	                return new InputObjectType(introspectionType);
	            } else if (introspectionType.kind === 'UNION') {
	                return new UnionType(introspectionType);
	            } else {
	                throw new Error('Unsupported type kind: ' + introspectionType.kind);
	            }
	        }
	    }]);
	
	    function Type(introspectionType) {
	        _classCallCheck(this, Type);
	
	        if (!(this.constructor !== Type)) {
	            throw new Error('Function  precondition failed: this.constructor !== Type');
	        }
	
	        if (!(typeof introspectionType.name === 'string')) {
	            throw new Error('Function  precondition failed: typeof introspectionType.name === \'string\'');
	        }
	
	        if (!(introspectionType.description === null || typeof introspectionType.description === 'string')) {
	            throw new Error('Function  precondition failed: introspectionType.description === null || typeof introspectionType.description === \'string\'');
	        }
	
	        this.name = introspectionType.name;
	        this.description = introspectionType.description;
	    }
	
	    return Type;
	}();
	
	var ObjectType = exports.ObjectType = function (_Type) {
	    _inherits(ObjectType, _Type);
	
	    function ObjectType(introspectionType) {
	        _classCallCheck(this, ObjectType);
	
	        if (!(introspectionType.kind === 'OBJECT')) {
	            throw new Error('Function  precondition failed: introspectionType.kind === \'OBJECT\'');
	        }
	
	        if (!Array.isArray(introspectionType.fields)) {
	            throw new Error('Function  precondition failed: Array.isArray(introspectionType.fields)');
	        }
	
	        if (!(introspectionType.interfaces === null || Array.isArray(introspectionType.interfaces))) {
	            throw new Error('Function  precondition failed: introspectionType.interfaces === null || Array.isArray(introspectionType.interfaces)');
	        }
	
	        var _this2 = _possibleConstructorReturn(this, (ObjectType.__proto__ || Object.getPrototypeOf(ObjectType)).call(this, introspectionType));
	
	        _this2.fields = introspectionType.fields.map(function (f) {
	            return new Field(f);
	        });
	
	        if (introspectionType.interfaces) {
	            _this2.interfaces = introspectionType.interfaces.map(function (r) {
	                return TypeRef.fromIntrospectionRef(r);
	            });
	        } else {
	            _this2.interfaces = [];
	        }
	        return _this2;
	    }
	
	    return ObjectType;
	}(Type);
	
	var UnionType = exports.UnionType = function (_Type2) {
	    _inherits(UnionType, _Type2);
	
	    function UnionType(introspectionType) {
	        _classCallCheck(this, UnionType);
	
	        if (!(introspectionType.kind === 'UNION')) {
	            throw new Error('Function  precondition failed: introspectionType.kind === \'UNION\'');
	        }
	
	        if (!(!introspectionType.possibleTypesArray || Array.isArray(introspectionType.possibleTypes))) {
	            throw new Error('Function  precondition failed: !introspectionType.possibleTypesArray || Array.isArray(introspectionType.possibleTypes)');
	        }
	
	        var _this3 = _possibleConstructorReturn(this, (UnionType.__proto__ || Object.getPrototypeOf(UnionType)).call(this, introspectionType));
	
	        _this3.possibleTypes = (introspectionType.possibleTypes || []).map(function (r) {
	            return TypeRef.fromIntrospectionRef(r);
	        });
	        return _this3;
	    }
	
	    return UnionType;
	}(Type);
	
	var ScalarType = exports.ScalarType = function (_Type3) {
	    _inherits(ScalarType, _Type3);
	
	    function ScalarType(introspectionType) {
	        _classCallCheck(this, ScalarType);
	
	        if (!(introspectionType.kind === 'SCALAR')) {
	            throw new Error('Function  precondition failed: introspectionType.kind === \'SCALAR\'');
	        }
	
	        return _possibleConstructorReturn(this, (ScalarType.__proto__ || Object.getPrototypeOf(ScalarType)).call(this, introspectionType));
	    }
	
	    return ScalarType;
	}(Type);
	
	var InterfaceType = exports.InterfaceType = function (_Type4) {
	    _inherits(InterfaceType, _Type4);
	
	    function InterfaceType(introspectionType) {
	        _classCallCheck(this, InterfaceType);
	
	        if (!(introspectionType.kind === 'INTERFACE')) {
	            throw new Error('Function  precondition failed: introspectionType.kind === \'INTERFACE\'');
	        }
	
	        if (!Array.isArray(introspectionType.fields)) {
	            throw new Error('Function  precondition failed: Array.isArray(introspectionType.fields)');
	        }
	
	        if (!(!introspectionType.possibleTypes || Array.isArray(introspectionType.possibleTypes))) {
	            throw new Error('Function  precondition failed: !introspectionType.possibleTypes || Array.isArray(introspectionType.possibleTypes)');
	        }
	
	        var _this5 = _possibleConstructorReturn(this, (InterfaceType.__proto__ || Object.getPrototypeOf(InterfaceType)).call(this, introspectionType));
	
	        _this5.fields = introspectionType.fields.map(function (f) {
	            return new Field(f);
	        });
	        _this5.possibleTypes = (introspectionType.possibleTypes || []).map(function (r) {
	            return TypeRef.fromIntrospectionRef(r);
	        });
	        return _this5;
	    }
	
	    return InterfaceType;
	}(Type);
	
	var EnumType = exports.EnumType = function (_Type5) {
	    _inherits(EnumType, _Type5);
	
	    function EnumType(introspectionType) {
	        _classCallCheck(this, EnumType);
	
	        if (!(introspectionType.kind === 'ENUM')) {
	            throw new Error('Function  precondition failed: introspectionType.kind === \'ENUM\'');
	        }
	
	        if (!Array.isArray(introspectionType.enumValues)) {
	            throw new Error('Function  precondition failed: Array.isArray(introspectionType.enumValues)');
	        }
	
	        var _this6 = _possibleConstructorReturn(this, (EnumType.__proto__ || Object.getPrototypeOf(EnumType)).call(this, introspectionType));
	
	        _this6.enumValues = introspectionType.enumValues.map(function (v) {
	            return new EnumValue(v);
	        });
	        return _this6;
	    }
	
	    return EnumType;
	}(Type);
	
	var InputObjectType = exports.InputObjectType = function (_Type6) {
	    _inherits(InputObjectType, _Type6);
	
	    function InputObjectType(introspectionType) {
	        _classCallCheck(this, InputObjectType);
	
	        if (!(introspectionType.kind === 'INPUT_OBJECT')) {
	            throw new Error('Function  precondition failed: introspectionType.kind === \'INPUT_OBJECT\'');
	        }
	
	        if (!Array.isArray(introspectionType.inputFields)) {
	            throw new Error('Function  precondition failed: Array.isArray(introspectionType.inputFields)');
	        }
	
	        var _this7 = _possibleConstructorReturn(this, (InputObjectType.__proto__ || Object.getPrototypeOf(InputObjectType)).call(this, introspectionType));
	
	        _this7.inputFields = introspectionType.inputFields.map(function (f) {
	            return new InputValue(f);
	        });
	        return _this7;
	    }
	
	    return InputObjectType;
	}(Type);
	
	var Field = exports.Field = function Field(introspectionField) {
	    _classCallCheck(this, Field);
	
	    if (!(typeof introspectionField.name === 'string')) {
	        throw new Error('Function  precondition failed: typeof introspectionField.name === \'string\'');
	    }
	
	    if (!(introspectionField.description === null || typeof introspectionField.description === 'string')) {
	        throw new Error('Function  precondition failed: introspectionField.description === null || typeof introspectionField.description === \'string\'');
	    }
	
	    if (!introspectionField.type) {
	        throw new Error('Function  precondition failed: introspectionField.type');
	    }
	
	    if (!Array.isArray(introspectionField.args)) {
	        throw new Error('Function  precondition failed: Array.isArray(introspectionField.args)');
	    }
	
	    if (!(!introspectionField.isDeprecated || typeof introspectionField.deprecationReason === 'string')) {
	        throw new Error('Function  precondition failed: !introspectionField.isDeprecated || typeof introspectionField.deprecationReason === \'string\'');
	    }
	
	    if (!(introspectionField.isDeprecated || introspectionField.deprecationReason === null)) {
	        throw new Error('Function  precondition failed: introspectionField.isDeprecated || introspectionField.deprecationReason === null');
	    }
	
	    this.name = introspectionField.name;
	    this.description = introspectionField.description;
	    this.args = introspectionField.args.map(function (a) {
	        return new InputValue(a);
	    });
	    this.type = TypeRef.fromIntrospectionRef(introspectionField.type);
	    this.isDeprecated = introspectionField.isDeprecated;
	    this.deprecationReason = introspectionField.deprecationReason;
	};
	
	var InputValue = exports.InputValue = function InputValue(introspectionValue) {
	    _classCallCheck(this, InputValue);
	
	    if (!(typeof introspectionValue.name === 'string')) {
	        throw new Error('Function  precondition failed: typeof introspectionValue.name === \'string\'');
	    }
	
	    if (!(introspectionValue.description === null || typeof introspectionValue.description === 'string')) {
	        throw new Error('Function  precondition failed: introspectionValue.description === null || typeof introspectionValue.description === \'string\'');
	    }
	
	    if (!introspectionValue.type) {
	        throw new Error('Function  precondition failed: introspectionValue.type');
	    }
	
	    if (!(introspectionValue.defaultValue !== undefined)) {
	        throw new Error('Function  precondition failed: introspectionValue.defaultValue !== undefined');
	    }
	
	    this.name = introspectionValue.name;
	    this.type = TypeRef.fromIntrospectionRef(introspectionValue.type);
	    this.description = introspectionValue.description;
	    this.defaultValue = introspectionValue.defaultValue;
	};
	
	var TypeRef = exports.TypeRef = function () {
	    function TypeRef() {
	        _classCallCheck(this, TypeRef);
	
	        if (!(this.constructor !== TypeRef)) {
	            throw new Error('Function  precondition failed: this.constructor !== TypeRef');
	        }
	    }
	
	    _createClass(TypeRef, null, [{
	        key: 'fromIntrospectionRef',
	        value: function fromIntrospectionRef(introspectionRef) {
	            if (introspectionRef.kind === 'NON_NULL') {
	                return new NonNullTypeRef(introspectionRef);
	            } else if (introspectionRef.kind === 'LIST') {
	                return new ListTypeRef(introspectionRef);
	            } else if (TYPE_KINDS.indexOf(introspectionRef.kind) !== -1) {
	                return new NamedTypeRef(introspectionRef);
	            } else {
	                throw new Error('Unsupported type ref kind: ' + introspectionRef.kind);
	            }
	        }
	    }]);
	
	    return TypeRef;
	}();
	
	var NonNullTypeRef = exports.NonNullTypeRef = function (_TypeRef) {
	    _inherits(NonNullTypeRef, _TypeRef);
	
	    function NonNullTypeRef(introspectionRef) {
	        _classCallCheck(this, NonNullTypeRef);
	
	        if (!introspectionRef.ofType) {
	            throw new Error('Function  precondition failed: introspectionRef.ofType');
	        }
	
	        var _this8 = _possibleConstructorReturn(this, (NonNullTypeRef.__proto__ || Object.getPrototypeOf(NonNullTypeRef)).call(this));
	
	        _this8.ofType = TypeRef.fromIntrospectionRef(introspectionRef.ofType);
	        return _this8;
	    }
	
	    return NonNullTypeRef;
	}(TypeRef);
	
	var NamedTypeRef = exports.NamedTypeRef = function (_TypeRef2) {
	    _inherits(NamedTypeRef, _TypeRef2);
	
	    function NamedTypeRef(introspectionRef) {
	        _classCallCheck(this, NamedTypeRef);
	
	        if (!(typeof introspectionRef.name === 'string')) {
	            throw new Error('Function  precondition failed: typeof introspectionRef.name === \'string\'');
	        }
	
	        var _this9 = _possibleConstructorReturn(this, (NamedTypeRef.__proto__ || Object.getPrototypeOf(NamedTypeRef)).call(this));
	
	        _this9.typeName = introspectionRef.name;
	        return _this9;
	    }
	
	    return NamedTypeRef;
	}(TypeRef);
	
	var ListTypeRef = exports.ListTypeRef = function (_TypeRef3) {
	    _inherits(ListTypeRef, _TypeRef3);
	
	    function ListTypeRef(introspectionRef) {
	        _classCallCheck(this, ListTypeRef);
	
	        if (!introspectionRef.ofType) {
	            throw new Error('Function  precondition failed: introspectionRef.ofType');
	        }
	
	        var _this10 = _possibleConstructorReturn(this, (ListTypeRef.__proto__ || Object.getPrototypeOf(ListTypeRef)).call(this));
	
	        _this10.ofType = TypeRef.fromIntrospectionRef(introspectionRef.ofType);
	        return _this10;
	    }
	
	    return ListTypeRef;
	}(TypeRef);
	
	var EnumValue = exports.EnumValue = function EnumValue(introspectionValue) {
	    _classCallCheck(this, EnumValue);
	
	    if (!(typeof introspectionValue.name === 'string')) {
	        throw new Error('Function  precondition failed: typeof introspectionValue.name === \'string\'');
	    }
	
	    if (!(introspectionValue.description === null || typeof introspectionValue.description === 'string')) {
	        throw new Error('Function  precondition failed: introspectionValue.description === null || typeof introspectionValue.description === \'string\'');
	    }
	
	    if (!(typeof introspectionValue.isDeprecated === 'boolean')) {
	        throw new Error('Function  precondition failed: typeof introspectionValue.isDeprecated === \'boolean\'');
	    }
	
	    if (!(!introspectionValue.isDeprecated || typeof introspectionValue.deprecationReason === 'string')) {
	        throw new Error('Function  precondition failed: !introspectionValue.isDeprecated || typeof introspectionValue.deprecationReason === \'string\'');
	    }
	
	    if (!(introspectionValue.isDeprecated || introspectionValue.deprecationReason === null)) {
	        throw new Error('Function  precondition failed: introspectionValue.isDeprecated || introspectionValue.deprecationReason === null');
	    }
	
	    this.name = introspectionValue.name;
	    this.description = introspectionValue.description;
	    this.isDeprecated = introspectionValue.isDeprecated;
	    this.deprecationReason = introspectionValue.deprecationReason;
	};

/***/ }),
/* 30 */
/***/ (function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	    value: true
	});
	exports.getReferencesInSchema = getReferencesInSchema;
	
	var _model = __webpack_require__(29);
	
	function getReferencesInSchema(schema) {
	    var visitQueue = [];
	    var visited = [];
	
	    visitQueue.push(schema.getQueryType().name);
	
	    var mutationType = schema.getMutationType();
	    if (mutationType) {
	        visitQueue.push(mutationType.name);
	    }
	
	    while (visitQueue.length) {
	        var typeId = visitQueue.shift();
	        if (visited.indexOf(typeId) !== -1) {
	            continue;
	        }
	
	        var type = schema.types[typeId];
	
	        if (!type) {
	            throw new Error('Type ' + typeId + ' not found in schema');
	        }
	
	        var newRefs = getReferencesInType(type);
	
	        visited.push(typeId);
	
	        [].push.apply(visitQueue, Object.keys(newRefs));
	    }
	
	    return visited;
	}
	
	function getReferencesInType(type) {
	    var refs = {};
	    addTypeToBag(type, refs);
	
	    if (type instanceof _model.ObjectType) {
	        type.fields.forEach(function (f) {
	            return getReferencesInField(f, refs);
	        });
	        type.interfaces.forEach(function (r) {
	            return addTypeRefToBag(r, refs);
	        });
	    }
	
	    if (type instanceof _model.InterfaceType) {
	        type.fields.forEach(function (f) {
	            return getReferencesInField(f, refs);
	        });
	        type.possibleTypes.forEach(function (r) {
	            return addTypeRefToBag(r, refs);
	        });
	    }
	
	    if (type instanceof _model.UnionType) {
	        type.possibleTypes.forEach(function (r) {
	            return addTypeRefToBag(r, refs);
	        });
	    }
	
	    if (type instanceof _model.InputObjectType) {
	        type.inputFields.forEach(function (iv) {
	            return addTypeRefToBag(iv.type, refs);
	        });
	    }
	
	    return refs;
	}
	
	function getReferencesInField(field, refs) {
	    addTypeRefToBag(field.type, refs);
	
	    field.args.forEach(function (arg) {
	        return addTypeRefToBag(arg.type, refs);
	    });
	}
	
	function addTypeRefToBag(typeRef, refs) {
	    if (typeRef instanceof _model.NonNullTypeRef) {
	        addTypeRefToBag(typeRef.ofType, refs);
	    } else if (typeRef instanceof _model.ListTypeRef) {
	        addTypeRefToBag(typeRef.ofType, refs);
	    } else if (typeRef instanceof _model.NamedTypeRef) {
	        refs[typeRef.typeName] = (refs[typeRef.typeName] || 0) + 1;
	    } else {
	        throw new Error('Unknown type ref: ' + typeRef.toString());
	    }
	}
	
	function addTypeToBag(type, refs) {
	    refs[type.name] = (refs[type.name] || 0) + 1;
	}

/***/ }),
/* 31 */
/***/ (function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	    value: true
	});
	exports.InputObjectDocsView = exports.ScalarDocsView = exports.EnumDocsView = exports.InterfaceDocsView = exports.UnionDocsView = exports.ObjectDocsView = undefined;
	
	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();
	
	var _react = __webpack_require__(1);
	
	var _react2 = _interopRequireDefault(_react);
	
	var _model = __webpack_require__(29);
	
	var _DescriptionView = __webpack_require__(32);
	
	var _DeprecatedView = __webpack_require__(38);
	
	var _FieldView = __webpack_require__(41);
	
	var _TypeRefView = __webpack_require__(43);
	
	var _FieldArgumentsTableView = __webpack_require__(49);
	
	var _TypeDocsViews = __webpack_require__(54);
	
	var StyleSheet = _interopRequireWildcard(_TypeDocsViews);
	
	function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }
	
	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
	
	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
	
	function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }
	
	function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }
	
	var ObjectDocsView = exports.ObjectDocsView = function (_React$Component) {
	    _inherits(ObjectDocsView, _React$Component);
	
	    function ObjectDocsView() {
	        _classCallCheck(this, ObjectDocsView);
	
	        return _possibleConstructorReturn(this, (ObjectDocsView.__proto__ || Object.getPrototypeOf(ObjectDocsView)).apply(this, arguments));
	    }
	
	    _createClass(ObjectDocsView, [{
	        key: 'render',
	        value: function render() {
	            var type = this.props.type;
	            return _react2.default.createElement(
	                'div',
	                { className: StyleSheet.type },
	                renderTitle(type.name, this.props.titleOverride),
	                renderDescription(type.description),
	                renderInterfaces(type.interfaces),
	                renderFields(type.fields)
	            );
	        }
	    }]);
	
	    return ObjectDocsView;
	}(_react2.default.Component);
	
	ObjectDocsView.defaultProps = {
	    titleOverride: null
	};
	
	var UnionDocsView = exports.UnionDocsView = function (_React$Component2) {
	    _inherits(UnionDocsView, _React$Component2);
	
	    function UnionDocsView() {
	        _classCallCheck(this, UnionDocsView);
	
	        return _possibleConstructorReturn(this, (UnionDocsView.__proto__ || Object.getPrototypeOf(UnionDocsView)).apply(this, arguments));
	    }
	
	    _createClass(UnionDocsView, [{
	        key: 'render',
	        value: function render() {
	            var type = this.props.type;
	            return _react2.default.createElement(
	                'div',
	                { className: StyleSheet.type },
	                renderTitle(type.name),
	                renderDescription(type.description),
	                renderPossibleTypes(type.possibleTypes)
	            );
	        }
	    }]);
	
	    return UnionDocsView;
	}(_react2.default.Component);
	
	var InterfaceDocsView = exports.InterfaceDocsView = function (_React$Component3) {
	    _inherits(InterfaceDocsView, _React$Component3);
	
	    function InterfaceDocsView() {
	        _classCallCheck(this, InterfaceDocsView);
	
	        return _possibleConstructorReturn(this, (InterfaceDocsView.__proto__ || Object.getPrototypeOf(InterfaceDocsView)).apply(this, arguments));
	    }
	
	    _createClass(InterfaceDocsView, [{
	        key: 'render',
	        value: function render() {
	            var type = this.props.type;
	            return _react2.default.createElement(
	                'div',
	                { className: StyleSheet.type },
	                renderTitle(type.name),
	                renderDescription(type.description),
	                renderImplementors(type.possibleTypes),
	                renderFields(type.fields)
	            );
	        }
	    }]);
	
	    return InterfaceDocsView;
	}(_react2.default.Component);
	
	var EnumDocsView = exports.EnumDocsView = function (_React$Component4) {
	    _inherits(EnumDocsView, _React$Component4);
	
	    function EnumDocsView() {
	        _classCallCheck(this, EnumDocsView);
	
	        return _possibleConstructorReturn(this, (EnumDocsView.__proto__ || Object.getPrototypeOf(EnumDocsView)).apply(this, arguments));
	    }
	
	    _createClass(EnumDocsView, [{
	        key: 'render',
	        value: function render() {
	            var type = this.props.type;
	            return _react2.default.createElement(
	                'div',
	                { className: StyleSheet.type },
	                renderTitle(type.name),
	                renderDescription(type.description),
	                renderEnumValues(type.enumValues)
	            );
	        }
	    }]);
	
	    return EnumDocsView;
	}(_react2.default.Component);
	
	var ScalarDocsView = exports.ScalarDocsView = function (_React$Component5) {
	    _inherits(ScalarDocsView, _React$Component5);
	
	    function ScalarDocsView() {
	        _classCallCheck(this, ScalarDocsView);
	
	        return _possibleConstructorReturn(this, (ScalarDocsView.__proto__ || Object.getPrototypeOf(ScalarDocsView)).apply(this, arguments));
	    }
	
	    _createClass(ScalarDocsView, [{
	        key: 'render',
	        value: function render() {
	            var type = this.props.type;
	            return _react2.default.createElement(
	                'div',
	                { className: StyleSheet.type },
	                renderTitle(type.name),
	                renderDescription(type.description)
	            );
	        }
	    }]);
	
	    return ScalarDocsView;
	}(_react2.default.Component);
	
	var InputObjectDocsView = exports.InputObjectDocsView = function (_React$Component6) {
	    _inherits(InputObjectDocsView, _React$Component6);
	
	    function InputObjectDocsView() {
	        _classCallCheck(this, InputObjectDocsView);
	
	        return _possibleConstructorReturn(this, (InputObjectDocsView.__proto__ || Object.getPrototypeOf(InputObjectDocsView)).apply(this, arguments));
	    }
	
	    _createClass(InputObjectDocsView, [{
	        key: 'render',
	        value: function render() {
	            var type = this.props.type;
	
	            return _react2.default.createElement(
	                'div',
	                { className: StyleSheet.type },
	                renderTitle(type.name),
	                renderDescription(type.description),
	                _react2.default.createElement(_FieldArgumentsTableView.FieldArgumentsTableView, {
	                    args: type.inputFields
	                })
	            );
	        }
	    }]);
	
	    return InputObjectDocsView;
	}(_react2.default.Component);
	
	function renderTitle(typeName) {
	    var titleOverride = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : null;
	
	    return _react2.default.createElement(
	        'h3',
	        { className: StyleSheet.heading },
	        _react2.default.createElement('a', { name: typeName }),
	        titleOverride || typeName
	    );
	}
	
	function renderDescription(description) {
	    if (!description) {
	        return null;
	    }
	
	    return _react2.default.createElement(
	        'div',
	        null,
	        _react2.default.createElement(_DescriptionView.DescriptionView, { description: description })
	    );
	}
	
	function renderFields(fields) {
	    return _react2.default.createElement(
	        'div',
	        null,
	        _react2.default.createElement(
	            'div',
	            { className: StyleSheet.subHeading },
	            'Fields'
	        ),
	        fields.map(function (f) {
	            return _react2.default.createElement(_FieldView.FieldView, { key: f.name, field: f });
	        })
	    );
	}
	
	function renderInterfaces(interfaces) {
	    if (!interfaces.length) {
	        return null;
	    }
	
	    return _react2.default.createElement(
	        'div',
	        null,
	        _react2.default.createElement(
	            'div',
	            { className: StyleSheet.subHeading },
	            'Implements'
	        ),
	        _react2.default.createElement(
	            'ul',
	            { className: StyleSheet.interfacesList },
	            interfaces.map(function (r, i) {
	                return _react2.default.createElement(
	                    'li',
	                    { key: i },
	                    _react2.default.createElement(_TypeRefView.TypeRefView, { key: i, typeRef: r })
	                );
	            })
	        )
	    );
	}
	
	function renderPossibleTypes(possibleTypes) {
	    if (!possibleTypes.length) {
	        return null;
	    }
	
	    return _react2.default.createElement(
	        'div',
	        null,
	        _react2.default.createElement(
	            'div',
	            { className: StyleSheet.subHeading },
	            'Possible Types'
	        ),
	        _react2.default.createElement(
	            'ul',
	            { className: StyleSheet.interfacesList },
	            possibleTypes.map(function (r, i) {
	                return _react2.default.createElement(
	                    'li',
	                    { key: i },
	                    _react2.default.createElement(_TypeRefView.TypeRefView, { key: i, typeRef: r })
	                );
	            })
	        )
	    );
	}
	
	function renderImplementors(possibleTypes) {
	    if (!possibleTypes.length) {
	        return null;
	    }
	
	    return _react2.default.createElement(
	        'div',
	        null,
	        _react2.default.createElement(
	            'div',
	            { className: StyleSheet.subHeading },
	            'Implemented by'
	        ),
	        _react2.default.createElement(
	            'ul',
	            { className: StyleSheet.interfacesList },
	            possibleTypes.map(function (r, i) {
	                return _react2.default.createElement(
	                    'li',
	                    { key: i },
	                    _react2.default.createElement(_TypeRefView.TypeRefView, { key: i, typeRef: r })
	                );
	            })
	        )
	    );
	}
	
	function renderEnumValues(enumValues) {
	    if (!enumValues.length) {
	        return null;
	    }
	
	    return _react2.default.createElement(
	        'div',
	        null,
	        _react2.default.createElement(
	            'div',
	            { className: StyleSheet.subHeading },
	            'Possible Enum Values'
	        ),
	        _react2.default.createElement(
	            'table',
	            null,
	            _react2.default.createElement(
	                'tbody',
	                null,
	                enumValues.map(function (v) {
	                    return _react2.default.createElement(
	                        'tr',
	                        {
	                            key: v.name,
	                            className: StyleSheet.enumRow
	                        },
	                        _react2.default.createElement(
	                            'td',
	                            {
	                                className: v.isDeprecated ? StyleSheet.enumNameDeprecated : StyleSheet.enumName
	                            },
	                            v.name
	                        ),
	                        _react2.default.createElement(
	                            'td',
	                            null,
	                            v.isDeprecated && _react2.default.createElement(_DeprecatedView.DeprecatedView, { reason: v.deprecationReason }) || v.description && _react2.default.createElement(_DescriptionView.DescriptionView, { description: v.description })
	                        )
	                    );
	                })
	            )
	        )
	    );
	}

/***/ }),
/* 32 */
/***/ (function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	    value: true
	});
	exports.DescriptionView = undefined;
	
	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();
	
	var _react = __webpack_require__(1);
	
	var _react2 = _interopRequireDefault(_react);
	
	var _marked = __webpack_require__(33);
	
	var _marked2 = _interopRequireDefault(_marked);
	
	var _DescriptionView = __webpack_require__(34);
	
	var StyleSheet = _interopRequireWildcard(_DescriptionView);
	
	function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }
	
	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
	
	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
	
	function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }
	
	function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }
	
	var DescriptionView = exports.DescriptionView = function (_React$Component) {
	    _inherits(DescriptionView, _React$Component);
	
	    function DescriptionView() {
	        _classCallCheck(this, DescriptionView);
	
	        return _possibleConstructorReturn(this, (DescriptionView.__proto__ || Object.getPrototypeOf(DescriptionView)).apply(this, arguments));
	    }
	
	    _createClass(DescriptionView, [{
	        key: 'render',
	        value: function render() {
	            var html = (0, _marked2.default)(this.props.description);
	
	            return _react2.default.createElement('div', {
	                className: [StyleSheet.container, this.props.className].join(' '),
	                dangerouslySetInnerHTML: { __html: html }
	            });
	        }
	    }]);
	
	    return DescriptionView;
	}(_react2.default.Component);
	
	DescriptionView.defaultProps = {
	    className: ''
	};

/***/ }),
/* 33 */
/***/ (function(module, exports, __webpack_require__) {

	/* WEBPACK VAR INJECTION */(function(global) {/**
	 * marked - a markdown parser
	 * Copyright (c) 2011-2014, Christopher Jeffrey. (MIT Licensed)
	 * https://github.com/markedjs/marked
	 */
	
	;(function(root) {
	'use strict';
	
	/**
	 * Block-Level Grammar
	 */
	
	var block = {
	  newline: /^\n+/,
	  code: /^( {4}[^\n]+\n*)+/,
	  fences: noop,
	  hr: /^ {0,3}((?:- *){3,}|(?:_ *){3,}|(?:\* *){3,})(?:\n+|$)/,
	  heading: /^ *(#{1,6}) *([^\n]+?) *#* *(?:\n+|$)/,
	  nptable: noop,
	  blockquote: /^( {0,3}> ?(paragraph|[^\n]*)(?:\n|$))+/,
	  list: /^( *)(bull) [\s\S]+?(?:hr|def|\n{2,}(?! )(?!\1bull )\n*|\s*$)/,
	  html: /^ *(?:comment *(?:\n|\s*$)|closed *(?:\n{2,}|\s*$)|closing *(?:\n{2,}|\s*$))/,
	  def: /^ {0,3}\[(label)\]: *\n? *<?([^\s>]+)>?(?:(?: +\n? *| *\n *)(title))? *(?:\n+|$)/,
	  table: noop,
	  lheading: /^([^\n]+)\n *(=|-){2,} *(?:\n+|$)/,
	  paragraph: /^([^\n]+(?:\n?(?!hr|heading|lheading| {0,3}>|tag)[^\n]+)+)/,
	  text: /^[^\n]+/
	};
	
	block._label = /(?:\\[\[\]]|[^\[\]])+/;
	block._title = /(?:"(?:\\"|[^"]|"[^"\n]*")*"|'\n?(?:[^'\n]+\n?)*'|\([^()]*\))/;
	block.def = edit(block.def)
	  .replace('label', block._label)
	  .replace('title', block._title)
	  .getRegex();
	
	block.bullet = /(?:[*+-]|\d+\.)/;
	block.item = /^( *)(bull) [^\n]*(?:\n(?!\1bull )[^\n]*)*/;
	block.item = edit(block.item, 'gm')
	  .replace(/bull/g, block.bullet)
	  .getRegex();
	
	block.list = edit(block.list)
	  .replace(/bull/g, block.bullet)
	  .replace('hr', '\\n+(?=\\1?(?:(?:- *){3,}|(?:_ *){3,}|(?:\\* *){3,})(?:\\n+|$))')
	  .replace('def', '\\n+(?=' + block.def.source + ')')
	  .getRegex();
	
	block._tag = '(?!(?:'
	  + 'a|em|strong|small|s|cite|q|dfn|abbr|data|time|code'
	  + '|var|samp|kbd|sub|sup|i|b|u|mark|ruby|rt|rp|bdi|bdo'
	  + '|span|br|wbr|ins|del|img)\\b)\\w+(?!:|[^\\w\\s@]*@)\\b';
	
	block.html = edit(block.html)
	  .replace('comment', /<!--[\s\S]*?-->/)
	  .replace('closed', /<(tag)[\s\S]+?<\/\1>/)
	  .replace('closing', /<tag(?:"[^"]*"|'[^']*'|\s[^'"\/>\s]*)*?\/?>/)
	  .replace(/tag/g, block._tag)
	  .getRegex();
	
	block.paragraph = edit(block.paragraph)
	  .replace('hr', block.hr)
	  .replace('heading', block.heading)
	  .replace('lheading', block.lheading)
	  .replace('tag', '<' + block._tag)
	  .getRegex();
	
	block.blockquote = edit(block.blockquote)
	  .replace('paragraph', block.paragraph)
	  .getRegex();
	
	/**
	 * Normal Block Grammar
	 */
	
	block.normal = merge({}, block);
	
	/**
	 * GFM Block Grammar
	 */
	
	block.gfm = merge({}, block.normal, {
	  fences: /^ *(`{3,}|~{3,})[ \.]*(\S+)? *\n([\s\S]*?)\n? *\1 *(?:\n+|$)/,
	  paragraph: /^/,
	  heading: /^ *(#{1,6}) +([^\n]+?) *#* *(?:\n+|$)/
	});
	
	block.gfm.paragraph = edit(block.paragraph)
	  .replace('(?!', '(?!'
	    + block.gfm.fences.source.replace('\\1', '\\2') + '|'
	    + block.list.source.replace('\\1', '\\3') + '|')
	  .getRegex();
	
	/**
	 * GFM + Tables Block Grammar
	 */
	
	block.tables = merge({}, block.gfm, {
	  nptable: /^ *(\S.*\|.*)\n *([-:]+ *\|[-| :]*)\n((?:.*\|.*(?:\n|$))*)\n*/,
	  table: /^ *\|(.+)\n *\|( *[-:]+[-| :]*)\n((?: *\|.*(?:\n|$))*)\n*/
	});
	
	/**
	 * Block Lexer
	 */
	
	function Lexer(options) {
	  this.tokens = [];
	  this.tokens.links = {};
	  this.options = options || marked.defaults;
	  this.rules = block.normal;
	
	  if (this.options.gfm) {
	    if (this.options.tables) {
	      this.rules = block.tables;
	    } else {
	      this.rules = block.gfm;
	    }
	  }
	}
	
	/**
	 * Expose Block Rules
	 */
	
	Lexer.rules = block;
	
	/**
	 * Static Lex Method
	 */
	
	Lexer.lex = function(src, options) {
	  var lexer = new Lexer(options);
	  return lexer.lex(src);
	};
	
	/**
	 * Preprocessing
	 */
	
	Lexer.prototype.lex = function(src) {
	  src = src
	    .replace(/\r\n|\r/g, '\n')
	    .replace(/\t/g, '    ')
	    .replace(/\u00a0/g, ' ')
	    .replace(/\u2424/g, '\n');
	
	  return this.token(src, true);
	};
	
	/**
	 * Lexing
	 */
	
	Lexer.prototype.token = function(src, top) {
	  src = src.replace(/^ +$/gm, '');
	  var next,
	      loose,
	      cap,
	      bull,
	      b,
	      item,
	      space,
	      i,
	      tag,
	      l,
	      isordered;
	
	  while (src) {
	    // newline
	    if (cap = this.rules.newline.exec(src)) {
	      src = src.substring(cap[0].length);
	      if (cap[0].length > 1) {
	        this.tokens.push({
	          type: 'space'
	        });
	      }
	    }
	
	    // code
	    if (cap = this.rules.code.exec(src)) {
	      src = src.substring(cap[0].length);
	      cap = cap[0].replace(/^ {4}/gm, '');
	      this.tokens.push({
	        type: 'code',
	        text: !this.options.pedantic
	          ? cap.replace(/\n+$/, '')
	          : cap
	      });
	      continue;
	    }
	
	    // fences (gfm)
	    if (cap = this.rules.fences.exec(src)) {
	      src = src.substring(cap[0].length);
	      this.tokens.push({
	        type: 'code',
	        lang: cap[2],
	        text: cap[3] || ''
	      });
	      continue;
	    }
	
	    // heading
	    if (cap = this.rules.heading.exec(src)) {
	      src = src.substring(cap[0].length);
	      this.tokens.push({
	        type: 'heading',
	        depth: cap[1].length,
	        text: cap[2]
	      });
	      continue;
	    }
	
	    // table no leading pipe (gfm)
	    if (top && (cap = this.rules.nptable.exec(src))) {
	      src = src.substring(cap[0].length);
	
	      item = {
	        type: 'table',
	        header: cap[1].replace(/^ *| *\| *$/g, '').split(/ *\| */),
	        align: cap[2].replace(/^ *|\| *$/g, '').split(/ *\| */),
	        cells: cap[3].replace(/\n$/, '').split('\n')
	      };
	
	      for (i = 0; i < item.align.length; i++) {
	        if (/^ *-+: *$/.test(item.align[i])) {
	          item.align[i] = 'right';
	        } else if (/^ *:-+: *$/.test(item.align[i])) {
	          item.align[i] = 'center';
	        } else if (/^ *:-+ *$/.test(item.align[i])) {
	          item.align[i] = 'left';
	        } else {
	          item.align[i] = null;
	        }
	      }
	
	      for (i = 0; i < item.cells.length; i++) {
	        item.cells[i] = item.cells[i].split(/ *\| */);
	      }
	
	      this.tokens.push(item);
	
	      continue;
	    }
	
	    // hr
	    if (cap = this.rules.hr.exec(src)) {
	      src = src.substring(cap[0].length);
	      this.tokens.push({
	        type: 'hr'
	      });
	      continue;
	    }
	
	    // blockquote
	    if (cap = this.rules.blockquote.exec(src)) {
	      src = src.substring(cap[0].length);
	
	      this.tokens.push({
	        type: 'blockquote_start'
	      });
	
	      cap = cap[0].replace(/^ *> ?/gm, '');
	
	      // Pass `top` to keep the current
	      // "toplevel" state. This is exactly
	      // how markdown.pl works.
	      this.token(cap, top);
	
	      this.tokens.push({
	        type: 'blockquote_end'
	      });
	
	      continue;
	    }
	
	    // list
	    if (cap = this.rules.list.exec(src)) {
	      src = src.substring(cap[0].length);
	      bull = cap[2];
	      isordered = bull.length > 1;
	
	      this.tokens.push({
	        type: 'list_start',
	        ordered: isordered,
	        start: isordered ? +bull : ''
	      });
	
	      // Get each top-level item.
	      cap = cap[0].match(this.rules.item);
	
	      next = false;
	      l = cap.length;
	      i = 0;
	
	      for (; i < l; i++) {
	        item = cap[i];
	
	        // Remove the list item's bullet
	        // so it is seen as the next token.
	        space = item.length;
	        item = item.replace(/^ *([*+-]|\d+\.) +/, '');
	
	        // Outdent whatever the
	        // list item contains. Hacky.
	        if (~item.indexOf('\n ')) {
	          space -= item.length;
	          item = !this.options.pedantic
	            ? item.replace(new RegExp('^ {1,' + space + '}', 'gm'), '')
	            : item.replace(/^ {1,4}/gm, '');
	        }
	
	        // Determine whether the next list item belongs here.
	        // Backpedal if it does not belong in this list.
	        if (this.options.smartLists && i !== l - 1) {
	          b = block.bullet.exec(cap[i + 1])[0];
	          if (bull !== b && !(bull.length > 1 && b.length > 1)) {
	            src = cap.slice(i + 1).join('\n') + src;
	            i = l - 1;
	          }
	        }
	
	        // Determine whether item is loose or not.
	        // Use: /(^|\n)(?! )[^\n]+\n\n(?!\s*$)/
	        // for discount behavior.
	        loose = next || /\n\n(?!\s*$)/.test(item);
	        if (i !== l - 1) {
	          next = item.charAt(item.length - 1) === '\n';
	          if (!loose) loose = next;
	        }
	
	        this.tokens.push({
	          type: loose
	            ? 'loose_item_start'
	            : 'list_item_start'
	        });
	
	        // Recurse.
	        this.token(item, false);
	
	        this.tokens.push({
	          type: 'list_item_end'
	        });
	      }
	
	      this.tokens.push({
	        type: 'list_end'
	      });
	
	      continue;
	    }
	
	    // html
	    if (cap = this.rules.html.exec(src)) {
	      src = src.substring(cap[0].length);
	      this.tokens.push({
	        type: this.options.sanitize
	          ? 'paragraph'
	          : 'html',
	        pre: !this.options.sanitizer
	          && (cap[1] === 'pre' || cap[1] === 'script' || cap[1] === 'style'),
	        text: cap[0]
	      });
	      continue;
	    }
	
	    // def
	    if (top && (cap = this.rules.def.exec(src))) {
	      src = src.substring(cap[0].length);
	      if (cap[3]) cap[3] = cap[3].substring(1, cap[3].length - 1);
	      tag = cap[1].toLowerCase();
	      if (!this.tokens.links[tag]) {
	        this.tokens.links[tag] = {
	          href: cap[2],
	          title: cap[3]
	        };
	      }
	      continue;
	    }
	
	    // table (gfm)
	    if (top && (cap = this.rules.table.exec(src))) {
	      src = src.substring(cap[0].length);
	
	      item = {
	        type: 'table',
	        header: cap[1].replace(/^ *| *\| *$/g, '').split(/ *\| */),
	        align: cap[2].replace(/^ *|\| *$/g, '').split(/ *\| */),
	        cells: cap[3].replace(/(?: *\| *)?\n$/, '').split('\n')
	      };
	
	      for (i = 0; i < item.align.length; i++) {
	        if (/^ *-+: *$/.test(item.align[i])) {
	          item.align[i] = 'right';
	        } else if (/^ *:-+: *$/.test(item.align[i])) {
	          item.align[i] = 'center';
	        } else if (/^ *:-+ *$/.test(item.align[i])) {
	          item.align[i] = 'left';
	        } else {
	          item.align[i] = null;
	        }
	      }
	
	      for (i = 0; i < item.cells.length; i++) {
	        item.cells[i] = item.cells[i]
	          .replace(/^ *\| *| *\| *$/g, '')
	          .split(/ *\| */);
	      }
	
	      this.tokens.push(item);
	
	      continue;
	    }
	
	    // lheading
	    if (cap = this.rules.lheading.exec(src)) {
	      src = src.substring(cap[0].length);
	      this.tokens.push({
	        type: 'heading',
	        depth: cap[2] === '=' ? 1 : 2,
	        text: cap[1]
	      });
	      continue;
	    }
	
	    // top-level paragraph
	    if (top && (cap = this.rules.paragraph.exec(src))) {
	      src = src.substring(cap[0].length);
	      this.tokens.push({
	        type: 'paragraph',
	        text: cap[1].charAt(cap[1].length - 1) === '\n'
	          ? cap[1].slice(0, -1)
	          : cap[1]
	      });
	      continue;
	    }
	
	    // text
	    if (cap = this.rules.text.exec(src)) {
	      // Top-level should never reach here.
	      src = src.substring(cap[0].length);
	      this.tokens.push({
	        type: 'text',
	        text: cap[0]
	      });
	      continue;
	    }
	
	    if (src) {
	      throw new Error('Infinite loop on byte: ' + src.charCodeAt(0));
	    }
	  }
	
	  return this.tokens;
	};
	
	/**
	 * Inline-Level Grammar
	 */
	
	var inline = {
	  escape: /^\\([\\`*{}\[\]()#+\-.!_>])/,
	  autolink: /^<(scheme:[^\s\x00-\x1f<>]*|email)>/,
	  url: noop,
	  tag: /^<!--[\s\S]*?-->|^<\/?[a-zA-Z0-9\-]+(?:"[^"]*"|'[^']*'|\s[^<'">\/\s]*)*?\/?>/,
	  link: /^!?\[(inside)\]\(href\)/,
	  reflink: /^!?\[(inside)\]\s*\[([^\]]*)\]/,
	  nolink: /^!?\[((?:\[[^\[\]]*\]|\\[\[\]]|[^\[\]])*)\]/,
	  strong: /^__([\s\S]+?)__(?!_)|^\*\*([\s\S]+?)\*\*(?!\*)/,
	  em: /^_([^\s_](?:[^_]|__)+?[^\s_])_\b|^\*((?:\*\*|[^*])+?)\*(?!\*)/,
	  code: /^(`+)\s*([\s\S]*?[^`]?)\s*\1(?!`)/,
	  br: /^ {2,}\n(?!\s*$)/,
	  del: noop,
	  text: /^[\s\S]+?(?=[\\<!\[`*]|\b_| {2,}\n|$)/
	};
	
	inline._scheme = /[a-zA-Z][a-zA-Z0-9+.-]{1,31}/;
	inline._email = /[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+(@)[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+(?![-_])/;
	
	inline.autolink = edit(inline.autolink)
	  .replace('scheme', inline._scheme)
	  .replace('email', inline._email)
	  .getRegex()
	
	inline._inside = /(?:\[[^\[\]]*\]|\\[\[\]]|[^\[\]]|\](?=[^\[]*\]))*/;
	inline._href = /\s*<?([\s\S]*?)>?(?:\s+['"]([\s\S]*?)['"])?\s*/;
	
	inline.link = edit(inline.link)
	  .replace('inside', inline._inside)
	  .replace('href', inline._href)
	  .getRegex();
	
	inline.reflink = edit(inline.reflink)
	  .replace('inside', inline._inside)
	  .getRegex();
	
	/**
	 * Normal Inline Grammar
	 */
	
	inline.normal = merge({}, inline);
	
	/**
	 * Pedantic Inline Grammar
	 */
	
	inline.pedantic = merge({}, inline.normal, {
	  strong: /^__(?=\S)([\s\S]*?\S)__(?!_)|^\*\*(?=\S)([\s\S]*?\S)\*\*(?!\*)/,
	  em: /^_(?=\S)([\s\S]*?\S)_(?!_)|^\*(?=\S)([\s\S]*?\S)\*(?!\*)/
	});
	
	/**
	 * GFM Inline Grammar
	 */
	
	inline.gfm = merge({}, inline.normal, {
	  escape: edit(inline.escape).replace('])', '~|])').getRegex(),
	  url: edit(/^((?:ftp|https?):\/\/|www\.)(?:[a-zA-Z0-9\-]+\.?)+[^\s<]*|^email/)
	    .replace('email', inline._email)
	    .getRegex(),
	  _backpedal: /(?:[^?!.,:;*_~()&]+|\([^)]*\)|&(?![a-zA-Z0-9]+;$)|[?!.,:;*_~)]+(?!$))+/,
	  del: /^~~(?=\S)([\s\S]*?\S)~~/,
	  text: edit(inline.text)
	    .replace(']|', '~]|')
	    .replace('|', '|https?://|ftp://|www\\.|[a-zA-Z0-9.!#$%&\'*+/=?^_`{\\|}~-]+@|')
	    .getRegex()
	});
	
	/**
	 * GFM + Line Breaks Inline Grammar
	 */
	
	inline.breaks = merge({}, inline.gfm, {
	  br: edit(inline.br).replace('{2,}', '*').getRegex(),
	  text: edit(inline.gfm.text).replace('{2,}', '*').getRegex()
	});
	
	/**
	 * Inline Lexer & Compiler
	 */
	
	function InlineLexer(links, options) {
	  this.options = options || marked.defaults;
	  this.links = links;
	  this.rules = inline.normal;
	  this.renderer = this.options.renderer || new Renderer();
	  this.renderer.options = this.options;
	
	  if (!this.links) {
	    throw new Error('Tokens array requires a `links` property.');
	  }
	
	  if (this.options.gfm) {
	    if (this.options.breaks) {
	      this.rules = inline.breaks;
	    } else {
	      this.rules = inline.gfm;
	    }
	  } else if (this.options.pedantic) {
	    this.rules = inline.pedantic;
	  }
	}
	
	/**
	 * Expose Inline Rules
	 */
	
	InlineLexer.rules = inline;
	
	/**
	 * Static Lexing/Compiling Method
	 */
	
	InlineLexer.output = function(src, links, options) {
	  var inline = new InlineLexer(links, options);
	  return inline.output(src);
	};
	
	/**
	 * Lexing/Compiling
	 */
	
	InlineLexer.prototype.output = function(src) {
	  var out = '',
	      link,
	      text,
	      href,
	      cap;
	
	  while (src) {
	    // escape
	    if (cap = this.rules.escape.exec(src)) {
	      src = src.substring(cap[0].length);
	      out += cap[1];
	      continue;
	    }
	
	    // autolink
	    if (cap = this.rules.autolink.exec(src)) {
	      src = src.substring(cap[0].length);
	      if (cap[2] === '@') {
	        text = escape(this.mangle(cap[1]));
	        href = 'mailto:' + text;
	      } else {
	        text = escape(cap[1]);
	        href = text;
	      }
	      out += this.renderer.link(href, null, text);
	      continue;
	    }
	
	    // url (gfm)
	    if (!this.inLink && (cap = this.rules.url.exec(src))) {
	      cap[0] = this.rules._backpedal.exec(cap[0])[0];
	      src = src.substring(cap[0].length);
	      if (cap[2] === '@') {
	        text = escape(cap[0]);
	        href = 'mailto:' + text;
	      } else {
	        text = escape(cap[0]);
	        if (cap[1] === 'www.') {
	          href = 'http://' + text;
	        } else {
	          href = text;
	        }
	      }
	      out += this.renderer.link(href, null, text);
	      continue;
	    }
	
	    // tag
	    if (cap = this.rules.tag.exec(src)) {
	      if (!this.inLink && /^<a /i.test(cap[0])) {
	        this.inLink = true;
	      } else if (this.inLink && /^<\/a>/i.test(cap[0])) {
	        this.inLink = false;
	      }
	      src = src.substring(cap[0].length);
	      out += this.options.sanitize
	        ? this.options.sanitizer
	          ? this.options.sanitizer(cap[0])
	          : escape(cap[0])
	        : cap[0]
	      continue;
	    }
	
	    // link
	    if (cap = this.rules.link.exec(src)) {
	      src = src.substring(cap[0].length);
	      this.inLink = true;
	      out += this.outputLink(cap, {
	        href: cap[2],
	        title: cap[3]
	      });
	      this.inLink = false;
	      continue;
	    }
	
	    // reflink, nolink
	    if ((cap = this.rules.reflink.exec(src))
	        || (cap = this.rules.nolink.exec(src))) {
	      src = src.substring(cap[0].length);
	      link = (cap[2] || cap[1]).replace(/\s+/g, ' ');
	      link = this.links[link.toLowerCase()];
	      if (!link || !link.href) {
	        out += cap[0].charAt(0);
	        src = cap[0].substring(1) + src;
	        continue;
	      }
	      this.inLink = true;
	      out += this.outputLink(cap, link);
	      this.inLink = false;
	      continue;
	    }
	
	    // strong
	    if (cap = this.rules.strong.exec(src)) {
	      src = src.substring(cap[0].length);
	      out += this.renderer.strong(this.output(cap[2] || cap[1]));
	      continue;
	    }
	
	    // em
	    if (cap = this.rules.em.exec(src)) {
	      src = src.substring(cap[0].length);
	      out += this.renderer.em(this.output(cap[2] || cap[1]));
	      continue;
	    }
	
	    // code
	    if (cap = this.rules.code.exec(src)) {
	      src = src.substring(cap[0].length);
	      out += this.renderer.codespan(escape(cap[2].trim(), true));
	      continue;
	    }
	
	    // br
	    if (cap = this.rules.br.exec(src)) {
	      src = src.substring(cap[0].length);
	      out += this.renderer.br();
	      continue;
	    }
	
	    // del (gfm)
	    if (cap = this.rules.del.exec(src)) {
	      src = src.substring(cap[0].length);
	      out += this.renderer.del(this.output(cap[1]));
	      continue;
	    }
	
	    // text
	    if (cap = this.rules.text.exec(src)) {
	      src = src.substring(cap[0].length);
	      out += this.renderer.text(escape(this.smartypants(cap[0])));
	      continue;
	    }
	
	    if (src) {
	      throw new Error('Infinite loop on byte: ' + src.charCodeAt(0));
	    }
	  }
	
	  return out;
	};
	
	/**
	 * Compile Link
	 */
	
	InlineLexer.prototype.outputLink = function(cap, link) {
	  var href = escape(link.href),
	      title = link.title ? escape(link.title) : null;
	
	  return cap[0].charAt(0) !== '!'
	    ? this.renderer.link(href, title, this.output(cap[1]))
	    : this.renderer.image(href, title, escape(cap[1]));
	};
	
	/**
	 * Smartypants Transformations
	 */
	
	InlineLexer.prototype.smartypants = function(text) {
	  if (!this.options.smartypants) return text;
	  return text
	    // em-dashes
	    .replace(/---/g, '\u2014')
	    // en-dashes
	    .replace(/--/g, '\u2013')
	    // opening singles
	    .replace(/(^|[-\u2014/(\[{"\s])'/g, '$1\u2018')
	    // closing singles & apostrophes
	    .replace(/'/g, '\u2019')
	    // opening doubles
	    .replace(/(^|[-\u2014/(\[{\u2018\s])"/g, '$1\u201c')
	    // closing doubles
	    .replace(/"/g, '\u201d')
	    // ellipses
	    .replace(/\.{3}/g, '\u2026');
	};
	
	/**
	 * Mangle Links
	 */
	
	InlineLexer.prototype.mangle = function(text) {
	  if (!this.options.mangle) return text;
	  var out = '',
	      l = text.length,
	      i = 0,
	      ch;
	
	  for (; i < l; i++) {
	    ch = text.charCodeAt(i);
	    if (Math.random() > 0.5) {
	      ch = 'x' + ch.toString(16);
	    }
	    out += '&#' + ch + ';';
	  }
	
	  return out;
	};
	
	/**
	 * Renderer
	 */
	
	function Renderer(options) {
	  this.options = options || {};
	}
	
	Renderer.prototype.code = function(code, lang, escaped) {
	  if (this.options.highlight) {
	    var out = this.options.highlight(code, lang);
	    if (out != null && out !== code) {
	      escaped = true;
	      code = out;
	    }
	  }
	
	  if (!lang) {
	    return '<pre><code>'
	      + (escaped ? code : escape(code, true))
	      + '\n</code></pre>';
	  }
	
	  return '<pre><code class="'
	    + this.options.langPrefix
	    + escape(lang, true)
	    + '">'
	    + (escaped ? code : escape(code, true))
	    + '\n</code></pre>\n';
	};
	
	Renderer.prototype.blockquote = function(quote) {
	  return '<blockquote>\n' + quote + '</blockquote>\n';
	};
	
	Renderer.prototype.html = function(html) {
	  return html;
	};
	
	Renderer.prototype.heading = function(text, level, raw) {
	  return '<h'
	    + level
	    + ' id="'
	    + this.options.headerPrefix
	    + raw.toLowerCase().replace(/[^\w]+/g, '-')
	    + '">'
	    + text
	    + '</h'
	    + level
	    + '>\n';
	};
	
	Renderer.prototype.hr = function() {
	  return this.options.xhtml ? '<hr/>\n' : '<hr>\n';
	};
	
	Renderer.prototype.list = function(body, ordered, start) {
	  var type = ordered ? 'ol' : 'ul',
	      startatt = (ordered && start !== 1) ? (' start="' + start + '"') : '';
	  return '<' + type + startatt + '>\n' + body + '</' + type + '>\n';
	};
	
	Renderer.prototype.listitem = function(text) {
	  return '<li>' + text + '</li>\n';
	};
	
	Renderer.prototype.paragraph = function(text) {
	  return '<p>' + text + '</p>\n';
	};
	
	Renderer.prototype.table = function(header, body) {
	  return '<table>\n'
	    + '<thead>\n'
	    + header
	    + '</thead>\n'
	    + '<tbody>\n'
	    + body
	    + '</tbody>\n'
	    + '</table>\n';
	};
	
	Renderer.prototype.tablerow = function(content) {
	  return '<tr>\n' + content + '</tr>\n';
	};
	
	Renderer.prototype.tablecell = function(content, flags) {
	  var type = flags.header ? 'th' : 'td';
	  var tag = flags.align
	    ? '<' + type + ' style="text-align:' + flags.align + '">'
	    : '<' + type + '>';
	  return tag + content + '</' + type + '>\n';
	};
	
	// span level renderer
	Renderer.prototype.strong = function(text) {
	  return '<strong>' + text + '</strong>';
	};
	
	Renderer.prototype.em = function(text) {
	  return '<em>' + text + '</em>';
	};
	
	Renderer.prototype.codespan = function(text) {
	  return '<code>' + text + '</code>';
	};
	
	Renderer.prototype.br = function() {
	  return this.options.xhtml ? '<br/>' : '<br>';
	};
	
	Renderer.prototype.del = function(text) {
	  return '<del>' + text + '</del>';
	};
	
	Renderer.prototype.link = function(href, title, text) {
	  if (this.options.sanitize) {
	    try {
	      var prot = decodeURIComponent(unescape(href))
	        .replace(/[^\w:]/g, '')
	        .toLowerCase();
	    } catch (e) {
	      return text;
	    }
	    if (prot.indexOf('javascript:') === 0 || prot.indexOf('vbscript:') === 0 || prot.indexOf('data:') === 0) {
	      return text;
	    }
	  }
	  if (this.options.baseUrl && !originIndependentUrl.test(href)) {
	    href = resolveUrl(this.options.baseUrl, href);
	  }
	  var out = '<a href="' + href + '"';
	  if (title) {
	    out += ' title="' + title + '"';
	  }
	  out += '>' + text + '</a>';
	  return out;
	};
	
	Renderer.prototype.image = function(href, title, text) {
	  if (this.options.baseUrl && !originIndependentUrl.test(href)) {
	    href = resolveUrl(this.options.baseUrl, href);
	  }
	  var out = '<img src="' + href + '" alt="' + text + '"';
	  if (title) {
	    out += ' title="' + title + '"';
	  }
	  out += this.options.xhtml ? '/>' : '>';
	  return out;
	};
	
	Renderer.prototype.text = function(text) {
	  return text;
	};
	
	/**
	 * TextRenderer
	 * returns only the textual part of the token
	 */
	
	function TextRenderer() {}
	
	// no need for block level renderers
	
	TextRenderer.prototype.strong =
	TextRenderer.prototype.em =
	TextRenderer.prototype.codespan =
	TextRenderer.prototype.del =
	TextRenderer.prototype.text = function (text) {
	  return text;
	}
	
	TextRenderer.prototype.link =
	TextRenderer.prototype.image = function(href, title, text) {
	  return '' + text;
	}
	
	TextRenderer.prototype.br = function() {
	  return '';
	}
	
	/**
	 * Parsing & Compiling
	 */
	
	function Parser(options) {
	  this.tokens = [];
	  this.token = null;
	  this.options = options || marked.defaults;
	  this.options.renderer = this.options.renderer || new Renderer();
	  this.renderer = this.options.renderer;
	  this.renderer.options = this.options;
	}
	
	/**
	 * Static Parse Method
	 */
	
	Parser.parse = function(src, options) {
	  var parser = new Parser(options);
	  return parser.parse(src);
	};
	
	/**
	 * Parse Loop
	 */
	
	Parser.prototype.parse = function(src) {
	  this.inline = new InlineLexer(src.links, this.options);
	  // use an InlineLexer with a TextRenderer to extract pure text
	  this.inlineText = new InlineLexer(
	    src.links,
	    merge({}, this.options, {renderer: new TextRenderer()})
	  );
	  this.tokens = src.reverse();
	
	  var out = '';
	  while (this.next()) {
	    out += this.tok();
	  }
	
	  return out;
	};
	
	/**
	 * Next Token
	 */
	
	Parser.prototype.next = function() {
	  return this.token = this.tokens.pop();
	};
	
	/**
	 * Preview Next Token
	 */
	
	Parser.prototype.peek = function() {
	  return this.tokens[this.tokens.length - 1] || 0;
	};
	
	/**
	 * Parse Text Tokens
	 */
	
	Parser.prototype.parseText = function() {
	  var body = this.token.text;
	
	  while (this.peek().type === 'text') {
	    body += '\n' + this.next().text;
	  }
	
	  return this.inline.output(body);
	};
	
	/**
	 * Parse Current Token
	 */
	
	Parser.prototype.tok = function() {
	  switch (this.token.type) {
	    case 'space': {
	      return '';
	    }
	    case 'hr': {
	      return this.renderer.hr();
	    }
	    case 'heading': {
	      return this.renderer.heading(
	        this.inline.output(this.token.text),
	        this.token.depth,
	        unescape(this.inlineText.output(this.token.text)));
	    }
	    case 'code': {
	      return this.renderer.code(this.token.text,
	        this.token.lang,
	        this.token.escaped);
	    }
	    case 'table': {
	      var header = '',
	          body = '',
	          i,
	          row,
	          cell,
	          j;
	
	      // header
	      cell = '';
	      for (i = 0; i < this.token.header.length; i++) {
	        cell += this.renderer.tablecell(
	          this.inline.output(this.token.header[i]),
	          { header: true, align: this.token.align[i] }
	        );
	      }
	      header += this.renderer.tablerow(cell);
	
	      for (i = 0; i < this.token.cells.length; i++) {
	        row = this.token.cells[i];
	
	        cell = '';
	        for (j = 0; j < row.length; j++) {
	          cell += this.renderer.tablecell(
	            this.inline.output(row[j]),
	            { header: false, align: this.token.align[j] }
	          );
	        }
	
	        body += this.renderer.tablerow(cell);
	      }
	      return this.renderer.table(header, body);
	    }
	    case 'blockquote_start': {
	      body = '';
	
	      while (this.next().type !== 'blockquote_end') {
	        body += this.tok();
	      }
	
	      return this.renderer.blockquote(body);
	    }
	    case 'list_start': {
	      body = '';
	      var ordered = this.token.ordered,
	          start = this.token.start;
	
	      while (this.next().type !== 'list_end') {
	        body += this.tok();
	      }
	
	      return this.renderer.list(body, ordered, start);
	    }
	    case 'list_item_start': {
	      body = '';
	
	      while (this.next().type !== 'list_item_end') {
	        body += this.token.type === 'text'
	          ? this.parseText()
	          : this.tok();
	      }
	
	      return this.renderer.listitem(body);
	    }
	    case 'loose_item_start': {
	      body = '';
	
	      while (this.next().type !== 'list_item_end') {
	        body += this.tok();
	      }
	
	      return this.renderer.listitem(body);
	    }
	    case 'html': {
	      var html = !this.token.pre && !this.options.pedantic
	        ? this.inline.output(this.token.text)
	        : this.token.text;
	      return this.renderer.html(html);
	    }
	    case 'paragraph': {
	      return this.renderer.paragraph(this.inline.output(this.token.text));
	    }
	    case 'text': {
	      return this.renderer.paragraph(this.parseText());
	    }
	  }
	};
	
	/**
	 * Helpers
	 */
	
	function escape(html, encode) {
	  return html
	    .replace(!encode ? /&(?!#?\w+;)/g : /&/g, '&amp;')
	    .replace(/</g, '&lt;')
	    .replace(/>/g, '&gt;')
	    .replace(/"/g, '&quot;')
	    .replace(/'/g, '&#39;');
	}
	
	function unescape(html) {
	  // explicitly match decimal, hex, and named HTML entities
	  return html.replace(/&(#(?:\d+)|(?:#x[0-9A-Fa-f]+)|(?:\w+));?/ig, function(_, n) {
	    n = n.toLowerCase();
	    if (n === 'colon') return ':';
	    if (n.charAt(0) === '#') {
	      return n.charAt(1) === 'x'
	        ? String.fromCharCode(parseInt(n.substring(2), 16))
	        : String.fromCharCode(+n.substring(1));
	    }
	    return '';
	  });
	}
	
	function edit(regex, opt) {
	  regex = regex.source;
	  opt = opt || '';
	  return {
	    replace: function(name, val) {
	      val = val.source || val;
	      val = val.replace(/(^|[^\[])\^/g, '$1');
	      regex = regex.replace(name, val);
	      return this;
	    },
	    getRegex: function() {
	      return new RegExp(regex, opt);
	    }
	  };
	}
	
	function resolveUrl(base, href) {
	  if (!baseUrls[' ' + base]) {
	    // we can ignore everything in base after the last slash of its path component,
	    // but we might need to add _that_
	    // https://tools.ietf.org/html/rfc3986#section-3
	    if (/^[^:]+:\/*[^/]*$/.test(base)) {
	      baseUrls[' ' + base] = base + '/';
	    } else {
	      baseUrls[' ' + base] = base.replace(/[^/]*$/, '');
	    }
	  }
	  base = baseUrls[' ' + base];
	
	  if (href.slice(0, 2) === '//') {
	    return base.replace(/:[\s\S]*/, ':') + href;
	  } else if (href.charAt(0) === '/') {
	    return base.replace(/(:\/*[^/]*)[\s\S]*/, '$1') + href;
	  } else {
	    return base + href;
	  }
	}
	var baseUrls = {};
	var originIndependentUrl = /^$|^[a-z][a-z0-9+.-]*:|^[?#]/i;
	
	function noop() {}
	noop.exec = noop;
	
	function merge(obj) {
	  var i = 1,
	      target,
	      key;
	
	  for (; i < arguments.length; i++) {
	    target = arguments[i];
	    for (key in target) {
	      if (Object.prototype.hasOwnProperty.call(target, key)) {
	        obj[key] = target[key];
	      }
	    }
	  }
	
	  return obj;
	}
	
	/**
	 * Marked
	 */
	
	function marked(src, opt, callback) {
	  // throw error in case of non string input
	  if (typeof src === 'undefined' || src === null) {
	    throw new Error('marked(): input parameter is undefined or null');
	  }
	  if (typeof src !== 'string') {
	    throw new Error('marked(): input parameter is of type '
	      + Object.prototype.toString.call(src) + ', string expected');
	  }
	
	  if (callback || typeof opt === 'function') {
	    if (!callback) {
	      callback = opt;
	      opt = null;
	    }
	
	    opt = merge({}, marked.defaults, opt || {});
	
	    var highlight = opt.highlight,
	        tokens,
	        pending,
	        i = 0;
	
	    try {
	      tokens = Lexer.lex(src, opt)
	    } catch (e) {
	      return callback(e);
	    }
	
	    pending = tokens.length;
	
	    var done = function(err) {
	      if (err) {
	        opt.highlight = highlight;
	        return callback(err);
	      }
	
	      var out;
	
	      try {
	        out = Parser.parse(tokens, opt);
	      } catch (e) {
	        err = e;
	      }
	
	      opt.highlight = highlight;
	
	      return err
	        ? callback(err)
	        : callback(null, out);
	    };
	
	    if (!highlight || highlight.length < 3) {
	      return done();
	    }
	
	    delete opt.highlight;
	
	    if (!pending) return done();
	
	    for (; i < tokens.length; i++) {
	      (function(token) {
	        if (token.type !== 'code') {
	          return --pending || done();
	        }
	        return highlight(token.text, token.lang, function(err, code) {
	          if (err) return done(err);
	          if (code == null || code === token.text) {
	            return --pending || done();
	          }
	          token.text = code;
	          token.escaped = true;
	          --pending || done();
	        });
	      })(tokens[i]);
	    }
	
	    return;
	  }
	  try {
	    if (opt) opt = merge({}, marked.defaults, opt);
	    return Parser.parse(Lexer.lex(src, opt), opt);
	  } catch (e) {
	    e.message += '\nPlease report this to https://github.com/markedjs/marked.';
	    if ((opt || marked.defaults).silent) {
	      return '<p>An error occurred:</p><pre>'
	        + escape(e.message + '', true)
	        + '</pre>';
	    }
	    throw e;
	  }
	}
	
	/**
	 * Options
	 */
	
	marked.options =
	marked.setOptions = function(opt) {
	  merge(marked.defaults, opt);
	  return marked;
	};
	
	marked.defaults = {
	  gfm: true,
	  tables: true,
	  breaks: false,
	  pedantic: false,
	  sanitize: false,
	  sanitizer: null,
	  mangle: true,
	  smartLists: false,
	  silent: false,
	  highlight: null,
	  langPrefix: 'lang-',
	  smartypants: false,
	  headerPrefix: '',
	  renderer: new Renderer(),
	  xhtml: false,
	  baseUrl: null
	};
	
	/**
	 * Expose
	 */
	
	marked.Parser = Parser;
	marked.parser = Parser.parse;
	
	marked.Renderer = Renderer;
	marked.TextRenderer = TextRenderer;
	
	marked.Lexer = Lexer;
	marked.lexer = Lexer.lex;
	
	marked.InlineLexer = InlineLexer;
	marked.inlineLexer = InlineLexer.output;
	
	marked.parse = marked;
	
	if (true) {
	  module.exports = marked;
	} else if (typeof define === 'function' && define.amd) {
	  define(function() { return marked; });
	} else {
	  root.marked = marked;
	}
	})(this || (typeof window !== 'undefined' ? window : global));
	
	/* WEBPACK VAR INJECTION */}.call(exports, (function() { return this; }())))

/***/ }),
/* 34 */
/***/ (function(module, exports, __webpack_require__) {

	// style-loader: Adds some css to the DOM by adding a <style> tag
	
	// load the styles
	var content = __webpack_require__(35);
	if(typeof content === 'string') content = [[module.id, content, '']];
	// add the styles to the DOM
	var update = __webpack_require__(37)(content, {});
	if(content.locals) module.exports = content.locals;
	// Hot Module Replacement
	if(false) {
		// When the styles change, update the <style> tags
		if(!content.locals) {
			module.hot.accept("!!../../node_modules/css-loader/index.js?modules&importLoaders=1!../../node_modules/postcss-loader/index.js!./DescriptionView.css", function() {
				var newContent = require("!!../../node_modules/css-loader/index.js?modules&importLoaders=1!../../node_modules/postcss-loader/index.js!./DescriptionView.css");
				if(typeof newContent === 'string') newContent = [[module.id, newContent, '']];
				update(newContent);
			});
		}
		// When the module is disposed, remove the <style> tags
		module.hot.dispose(function() { update(); });
	}

/***/ }),
/* 35 */
/***/ (function(module, exports, __webpack_require__) {

	exports = module.exports = __webpack_require__(36)();
	// imports
	
	
	// module
	exports.push([module.id, "._1S63EXzJ2LWrq2TSLX8cAu :first-child {\n    margin-top: 0;\n}\n\n._1S63EXzJ2LWrq2TSLX8cAu :last-child {\n    margin-bottom: 0;\n}\n\n._1S63EXzJ2LWrq2TSLX8cAu h1 {\n    font-size: 1.5em;\n}\n\n._1S63EXzJ2LWrq2TSLX8cAu h2 {\n    font-size: 1.3em;\n}\n\n._1S63EXzJ2LWrq2TSLX8cAu h3 {\n    font-size: 1.1em;\n    font-feature-settings: \"c2sc\";\n    font-variant: small-caps;\n}\n\n._1S63EXzJ2LWrq2TSLX8cAu blockquote {\n    border-left: 8px solid #e8e8e8;\n    margin-top: -0.3em;\n    padding-top: 0.3em;\n    margin-left: 20px;\n    padding-left: 12px;\n    margin-bottom: -0.5em;\n    padding-bottom: 0.5em;\n}\n", ""]);
	
	// exports
	exports.locals = {
		"container": "_1S63EXzJ2LWrq2TSLX8cAu"
	};

/***/ }),
/* 36 */
/***/ (function(module, exports) {

	/*
		MIT License http://www.opensource.org/licenses/mit-license.php
		Author Tobias Koppers @sokra
	*/
	// css base code, injected by the css-loader
	module.exports = function() {
		var list = [];
	
		// return the list of modules as css string
		list.toString = function toString() {
			var result = [];
			for(var i = 0; i < this.length; i++) {
				var item = this[i];
				if(item[2]) {
					result.push("@media " + item[2] + "{" + item[1] + "}");
				} else {
					result.push(item[1]);
				}
			}
			return result.join("");
		};
	
		// import a list of modules into the list
		list.i = function(modules, mediaQuery) {
			if(typeof modules === "string")
				modules = [[null, modules, ""]];
			var alreadyImportedModules = {};
			for(var i = 0; i < this.length; i++) {
				var id = this[i][0];
				if(typeof id === "number")
					alreadyImportedModules[id] = true;
			}
			for(i = 0; i < modules.length; i++) {
				var item = modules[i];
				// skip already imported module
				// this implementation is not 100% perfect for weird media query combinations
				//  when a module is imported multiple times with different media queries.
				//  I hope this will never occur (Hey this way we have smaller bundles)
				if(typeof item[0] !== "number" || !alreadyImportedModules[item[0]]) {
					if(mediaQuery && !item[2]) {
						item[2] = mediaQuery;
					} else if(mediaQuery) {
						item[2] = "(" + item[2] + ") and (" + mediaQuery + ")";
					}
					list.push(item);
				}
			}
		};
		return list;
	};


/***/ }),
/* 37 */
/***/ (function(module, exports, __webpack_require__) {

	/*
		MIT License http://www.opensource.org/licenses/mit-license.php
		Author Tobias Koppers @sokra
	*/
	var stylesInDom = {},
		memoize = function(fn) {
			var memo;
			return function () {
				if (typeof memo === "undefined") memo = fn.apply(this, arguments);
				return memo;
			};
		},
		isOldIE = memoize(function() {
			return /msie [6-9]\b/.test(self.navigator.userAgent.toLowerCase());
		}),
		getHeadElement = memoize(function () {
			return document.head || document.getElementsByTagName("head")[0];
		}),
		singletonElement = null,
		singletonCounter = 0,
		styleElementsInsertedAtTop = [];
	
	module.exports = function(list, options) {
		if(false) {
			if(typeof document !== "object") throw new Error("The style-loader cannot be used in a non-browser environment");
		}
	
		options = options || {};
		// Force single-tag solution on IE6-9, which has a hard limit on the # of <style>
		// tags it will allow on a page
		if (typeof options.singleton === "undefined") options.singleton = isOldIE();
	
		// By default, add <style> tags to the bottom of <head>.
		if (typeof options.insertAt === "undefined") options.insertAt = "bottom";
	
		var styles = listToStyles(list);
		addStylesToDom(styles, options);
	
		return function update(newList) {
			var mayRemove = [];
			for(var i = 0; i < styles.length; i++) {
				var item = styles[i];
				var domStyle = stylesInDom[item.id];
				domStyle.refs--;
				mayRemove.push(domStyle);
			}
			if(newList) {
				var newStyles = listToStyles(newList);
				addStylesToDom(newStyles, options);
			}
			for(var i = 0; i < mayRemove.length; i++) {
				var domStyle = mayRemove[i];
				if(domStyle.refs === 0) {
					for(var j = 0; j < domStyle.parts.length; j++)
						domStyle.parts[j]();
					delete stylesInDom[domStyle.id];
				}
			}
		};
	}
	
	function addStylesToDom(styles, options) {
		for(var i = 0; i < styles.length; i++) {
			var item = styles[i];
			var domStyle = stylesInDom[item.id];
			if(domStyle) {
				domStyle.refs++;
				for(var j = 0; j < domStyle.parts.length; j++) {
					domStyle.parts[j](item.parts[j]);
				}
				for(; j < item.parts.length; j++) {
					domStyle.parts.push(addStyle(item.parts[j], options));
				}
			} else {
				var parts = [];
				for(var j = 0; j < item.parts.length; j++) {
					parts.push(addStyle(item.parts[j], options));
				}
				stylesInDom[item.id] = {id: item.id, refs: 1, parts: parts};
			}
		}
	}
	
	function listToStyles(list) {
		var styles = [];
		var newStyles = {};
		for(var i = 0; i < list.length; i++) {
			var item = list[i];
			var id = item[0];
			var css = item[1];
			var media = item[2];
			var sourceMap = item[3];
			var part = {css: css, media: media, sourceMap: sourceMap};
			if(!newStyles[id])
				styles.push(newStyles[id] = {id: id, parts: [part]});
			else
				newStyles[id].parts.push(part);
		}
		return styles;
	}
	
	function insertStyleElement(options, styleElement) {
		var head = getHeadElement();
		var lastStyleElementInsertedAtTop = styleElementsInsertedAtTop[styleElementsInsertedAtTop.length - 1];
		if (options.insertAt === "top") {
			if(!lastStyleElementInsertedAtTop) {
				head.insertBefore(styleElement, head.firstChild);
			} else if(lastStyleElementInsertedAtTop.nextSibling) {
				head.insertBefore(styleElement, lastStyleElementInsertedAtTop.nextSibling);
			} else {
				head.appendChild(styleElement);
			}
			styleElementsInsertedAtTop.push(styleElement);
		} else if (options.insertAt === "bottom") {
			head.appendChild(styleElement);
		} else {
			throw new Error("Invalid value for parameter 'insertAt'. Must be 'top' or 'bottom'.");
		}
	}
	
	function removeStyleElement(styleElement) {
		styleElement.parentNode.removeChild(styleElement);
		var idx = styleElementsInsertedAtTop.indexOf(styleElement);
		if(idx >= 0) {
			styleElementsInsertedAtTop.splice(idx, 1);
		}
	}
	
	function createStyleElement(options) {
		var styleElement = document.createElement("style");
		styleElement.type = "text/css";
		insertStyleElement(options, styleElement);
		return styleElement;
	}
	
	function createLinkElement(options) {
		var linkElement = document.createElement("link");
		linkElement.rel = "stylesheet";
		insertStyleElement(options, linkElement);
		return linkElement;
	}
	
	function addStyle(obj, options) {
		var styleElement, update, remove;
	
		if (options.singleton) {
			var styleIndex = singletonCounter++;
			styleElement = singletonElement || (singletonElement = createStyleElement(options));
			update = applyToSingletonTag.bind(null, styleElement, styleIndex, false);
			remove = applyToSingletonTag.bind(null, styleElement, styleIndex, true);
		} else if(obj.sourceMap &&
			typeof URL === "function" &&
			typeof URL.createObjectURL === "function" &&
			typeof URL.revokeObjectURL === "function" &&
			typeof Blob === "function" &&
			typeof btoa === "function") {
			styleElement = createLinkElement(options);
			update = updateLink.bind(null, styleElement);
			remove = function() {
				removeStyleElement(styleElement);
				if(styleElement.href)
					URL.revokeObjectURL(styleElement.href);
			};
		} else {
			styleElement = createStyleElement(options);
			update = applyToTag.bind(null, styleElement);
			remove = function() {
				removeStyleElement(styleElement);
			};
		}
	
		update(obj);
	
		return function updateStyle(newObj) {
			if(newObj) {
				if(newObj.css === obj.css && newObj.media === obj.media && newObj.sourceMap === obj.sourceMap)
					return;
				update(obj = newObj);
			} else {
				remove();
			}
		};
	}
	
	var replaceText = (function () {
		var textStore = [];
	
		return function (index, replacement) {
			textStore[index] = replacement;
			return textStore.filter(Boolean).join('\n');
		};
	})();
	
	function applyToSingletonTag(styleElement, index, remove, obj) {
		var css = remove ? "" : obj.css;
	
		if (styleElement.styleSheet) {
			styleElement.styleSheet.cssText = replaceText(index, css);
		} else {
			var cssNode = document.createTextNode(css);
			var childNodes = styleElement.childNodes;
			if (childNodes[index]) styleElement.removeChild(childNodes[index]);
			if (childNodes.length) {
				styleElement.insertBefore(cssNode, childNodes[index]);
			} else {
				styleElement.appendChild(cssNode);
			}
		}
	}
	
	function applyToTag(styleElement, obj) {
		var css = obj.css;
		var media = obj.media;
	
		if(media) {
			styleElement.setAttribute("media", media)
		}
	
		if(styleElement.styleSheet) {
			styleElement.styleSheet.cssText = css;
		} else {
			while(styleElement.firstChild) {
				styleElement.removeChild(styleElement.firstChild);
			}
			styleElement.appendChild(document.createTextNode(css));
		}
	}
	
	function updateLink(linkElement, obj) {
		var css = obj.css;
		var sourceMap = obj.sourceMap;
	
		if(sourceMap) {
			// http://stackoverflow.com/a/26603875
			css += "\n/*# sourceMappingURL=data:application/json;base64," + btoa(unescape(encodeURIComponent(JSON.stringify(sourceMap)))) + " */";
		}
	
		var blob = new Blob([css], { type: "text/css" });
	
		var oldSrc = linkElement.href;
	
		linkElement.href = URL.createObjectURL(blob);
	
		if(oldSrc)
			URL.revokeObjectURL(oldSrc);
	}


/***/ }),
/* 38 */
/***/ (function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	    value: true
	});
	exports.DeprecatedView = undefined;
	
	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();
	
	var _react = __webpack_require__(1);
	
	var _react2 = _interopRequireDefault(_react);
	
	var _marked = __webpack_require__(33);
	
	var _marked2 = _interopRequireDefault(_marked);
	
	var _DeprecatedView = __webpack_require__(39);
	
	var StyleSheet = _interopRequireWildcard(_DeprecatedView);
	
	function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }
	
	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
	
	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
	
	function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }
	
	function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }
	
	var DeprecatedView = exports.DeprecatedView = function (_React$Component) {
	    _inherits(DeprecatedView, _React$Component);
	
	    function DeprecatedView() {
	        _classCallCheck(this, DeprecatedView);
	
	        return _possibleConstructorReturn(this, (DeprecatedView.__proto__ || Object.getPrototypeOf(DeprecatedView)).apply(this, arguments));
	    }
	
	    _createClass(DeprecatedView, [{
	        key: 'render',
	        value: function render() {
	            var html = (0, _marked2.default)('[DEPRECATED] ' + this.props.reason);
	
	            return _react2.default.createElement('div', {
	                className: [StyleSheet.container, this.props.className].join(' '),
	                dangerouslySetInnerHTML: { __html: html }
	            });
	        }
	    }]);
	
	    return DeprecatedView;
	}(_react2.default.Component);
	
	DeprecatedView.defaultProps = {
	    className: ''
	};

/***/ }),
/* 39 */
/***/ (function(module, exports, __webpack_require__) {

	// style-loader: Adds some css to the DOM by adding a <style> tag
	
	// load the styles
	var content = __webpack_require__(40);
	if(typeof content === 'string') content = [[module.id, content, '']];
	// add the styles to the DOM
	var update = __webpack_require__(37)(content, {});
	if(content.locals) module.exports = content.locals;
	// Hot Module Replacement
	if(false) {
		// When the styles change, update the <style> tags
		if(!content.locals) {
			module.hot.accept("!!../../node_modules/css-loader/index.js?modules&importLoaders=1!../../node_modules/postcss-loader/index.js!./DeprecatedView.css", function() {
				var newContent = require("!!../../node_modules/css-loader/index.js?modules&importLoaders=1!../../node_modules/postcss-loader/index.js!./DeprecatedView.css");
				if(typeof newContent === 'string') newContent = [[module.id, newContent, '']];
				update(newContent);
			});
		}
		// When the module is disposed, remove the <style> tags
		module.hot.dispose(function() { update(); });
	}

/***/ }),
/* 40 */
/***/ (function(module, exports, __webpack_require__) {

	exports = module.exports = __webpack_require__(36)();
	// imports
	
	
	// module
	exports.push([module.id, "._3vR6_dnRDTk7bHCVHkPY-v :first-child {\n    margin-top: 0;\n}\n\n._3vR6_dnRDTk7bHCVHkPY-v :last-child {\n    margin-bottom: 0;\n}\n\n._3vR6_dnRDTk7bHCVHkPY-v h1 {\n    font-size: 1.3em;\n}\n\n._3vR6_dnRDTk7bHCVHkPY-v h2 {\n    font-size: 1.1em;\n}\n\n._3vR6_dnRDTk7bHCVHkPY-v h3 {\n    font-size: 1em;\n    font-feature-settings: \"c2sc\";\n    font-variant: small-caps;\n}\n\n._3vR6_dnRDTk7bHCVHkPY-v blockquote {\n    border-left: 8px solid #e8e8e8;\n    margin-top: -0.3em;\n    padding-top: 0.3em;\n    margin-left: 20px;\n    padding-left: 12px;\n    margin-bottom: -0.5em;\n    padding-bottom: 0.5em;\n}\n", ""]);
	
	// exports
	exports.locals = {
		"container": "_3vR6_dnRDTk7bHCVHkPY-v"
	};

/***/ }),
/* 41 */
/***/ (function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	    value: true
	});
	exports.FieldView = undefined;
	
	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();
	
	var _react = __webpack_require__(1);
	
	var _react2 = _interopRequireDefault(_react);
	
	var _model = __webpack_require__(29);
	
	var _DescriptionView = __webpack_require__(32);
	
	var _DeprecatedView = __webpack_require__(38);
	
	var _FieldSyntaxView = __webpack_require__(42);
	
	var _FieldArgumentsTableView = __webpack_require__(49);
	
	var _FieldView = __webpack_require__(52);
	
	var StyleSheet = _interopRequireWildcard(_FieldView);
	
	function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }
	
	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
	
	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
	
	function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }
	
	function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }
	
	var FieldView = exports.FieldView = function (_React$Component) {
	    _inherits(FieldView, _React$Component);
	
	    function FieldView() {
	        _classCallCheck(this, FieldView);
	
	        return _possibleConstructorReturn(this, (FieldView.__proto__ || Object.getPrototypeOf(FieldView)).apply(this, arguments));
	    }
	
	    _createClass(FieldView, [{
	        key: 'render',
	        value: function render() {
	            var field = this.props.field;
	
	            return _react2.default.createElement(
	                'div',
	                {
	                    key: field.name,
	                    className: StyleSheet.container
	                },
	                _react2.default.createElement(_FieldSyntaxView.FieldSyntaxView, { field: field }),
	                this.renderDescription(field.description),
	                this.renderDeprecated(field.isDeprecated, field.deprecationReason),
	                _react2.default.createElement(_FieldArgumentsTableView.FieldArgumentsTableView, { args: field.args })
	            );
	        }
	    }, {
	        key: 'renderDescription',
	        value: function renderDescription(description) {
	            if (!description) {
	                return null;
	            }
	
	            return _react2.default.createElement(_DescriptionView.DescriptionView, {
	                className: StyleSheet.description,
	                description: description
	            });
	        }
	    }, {
	        key: 'renderDeprecated',
	        value: function renderDeprecated(isDeprecated, reason) {
	            if (!isDeprecated) {
	                return null;
	            }
	
	            return _react2.default.createElement(_DeprecatedView.DeprecatedView, {
	                className: StyleSheet.deprecated,
	                reason: reason
	            });
	        }
	    }]);
	
	    return FieldView;
	}(_react2.default.Component);

/***/ }),
/* 42 */
/***/ (function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	    value: true
	});
	exports.FieldSyntaxView = undefined;
	
	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();
	
	var _react = __webpack_require__(1);
	
	var _react2 = _interopRequireDefault(_react);
	
	var _model = __webpack_require__(29);
	
	var _TypeRefView = __webpack_require__(43);
	
	var _FieldSyntaxView = __webpack_require__(47);
	
	var StyleSheet = _interopRequireWildcard(_FieldSyntaxView);
	
	function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }
	
	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
	
	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
	
	function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }
	
	function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }
	
	var FieldSyntaxView = exports.FieldSyntaxView = function (_React$Component) {
	    _inherits(FieldSyntaxView, _React$Component);
	
	    function FieldSyntaxView() {
	        _classCallCheck(this, FieldSyntaxView);
	
	        return _possibleConstructorReturn(this, (FieldSyntaxView.__proto__ || Object.getPrototypeOf(FieldSyntaxView)).apply(this, arguments));
	    }
	
	    _createClass(FieldSyntaxView, [{
	        key: 'render',
	        value: function render() {
	            var field = this.props.field;
	
	            return _react2.default.createElement(
	                'div',
	                { className: StyleSheet.container },
	                _react2.default.createElement(
	                    'span',
	                    { className: StyleSheet.name },
	                    field.name
	                ),
	                this.renderFieldArgs(field.args),
	                ': ',
	                _react2.default.createElement(_TypeRefView.TypeRefView, { typeRef: field.type })
	            );
	        }
	    }, {
	        key: 'renderFieldArgs',
	        value: function renderFieldArgs(args) {
	            var _this2 = this;
	
	            if (!args.length) {
	                return null;
	            }
	
	            return _react2.default.createElement(
	                'span',
	                null,
	                '(',
	                args.map(function (arg, idx) {
	                    return _this2.renderField(arg, idx);
	                }),
	                ')'
	            );
	        }
	    }, {
	        key: 'renderField',
	        value: function renderField(arg, index) {
	            return _react2.default.createElement(
	                'span',
	                { key: arg.name },
	                index > 0 ? _react2.default.createElement(
	                    'span',
	                    null,
	                    ', '
	                ) : null,
	                _react2.default.createElement(
	                    'span',
	                    { className: StyleSheet.argumentName },
	                    arg.name
	                ),
	                ': ',
	                _react2.default.createElement(_TypeRefView.TypeRefView, { typeRef: arg.type }),
	                this.renderDefaultValue(arg.defaultValue)
	            );
	        }
	    }, {
	        key: 'renderDefaultValue',
	        value: function renderDefaultValue(defaultValue) {
	            if (!defaultValue) {
	                return null;
	            }
	
	            return _react2.default.createElement(
	                'span',
	                { className: StyleSheet.defaultValue },
	                ' = ',
	                defaultValue
	            );
	        }
	    }]);
	
	    return FieldSyntaxView;
	}(_react2.default.Component);

/***/ }),
/* 43 */
/***/ (function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	    value: true
	});
	exports.TypeRefView = undefined;
	
	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();
	
	var _react = __webpack_require__(1);
	
	var _react2 = _interopRequireDefault(_react);
	
	var _model = __webpack_require__(29);
	
	var _TypeRefView = __webpack_require__(44);
	
	var StyleSheet = _interopRequireWildcard(_TypeRefView);
	
	function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }
	
	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
	
	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
	
	function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }
	
	function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }
	
	var TypeRefView = exports.TypeRefView = function (_React$Component) {
	    _inherits(TypeRefView, _React$Component);
	
	    function TypeRefView() {
	        _classCallCheck(this, TypeRefView);
	
	        return _possibleConstructorReturn(this, (TypeRefView.__proto__ || Object.getPrototypeOf(TypeRefView)).apply(this, arguments));
	    }
	
	    _createClass(TypeRefView, [{
	        key: 'render',
	        value: function render() {
	            var ref = this.props.typeRef;
	
	            if (ref instanceof _model.NamedTypeRef) {
	                return _react2.default.createElement(
	                    'a',
	                    {
	                        className: StyleSheet.typeRef,
	                        href: '#' + ref.typeName
	                    },
	                    ref.typeName
	                );
	            } else if (ref instanceof _model.NonNullTypeRef) {
	                return _react2.default.createElement(
	                    'span',
	                    null,
	                    _react2.default.createElement(TypeRefView, { typeRef: ref.ofType }),
	                    '!'
	                );
	            } else if (ref instanceof _model.ListTypeRef) {
	                return _react2.default.createElement(
	                    'span',
	                    null,
	                    '[',
	                    _react2.default.createElement(TypeRefView, { typeRef: ref.ofType }),
	                    ']'
	                );
	            }
	
	            throw new Error('Unknown type ref: ' + ref.toString());
	        }
	    }]);
	
	    return TypeRefView;
	}(_react2.default.Component);

/***/ }),
/* 44 */
/***/ (function(module, exports, __webpack_require__) {

	// style-loader: Adds some css to the DOM by adding a <style> tag
	
	// load the styles
	var content = __webpack_require__(45);
	if(typeof content === 'string') content = [[module.id, content, '']];
	// add the styles to the DOM
	var update = __webpack_require__(37)(content, {});
	if(content.locals) module.exports = content.locals;
	// Hot Module Replacement
	if(false) {
		// When the styles change, update the <style> tags
		if(!content.locals) {
			module.hot.accept("!!../../node_modules/css-loader/index.js?modules&importLoaders=1!../../node_modules/postcss-loader/index.js!./TypeRefView.css", function() {
				var newContent = require("!!../../node_modules/css-loader/index.js?modules&importLoaders=1!../../node_modules/postcss-loader/index.js!./TypeRefView.css");
				if(typeof newContent === 'string') newContent = [[module.id, newContent, '']];
				update(newContent);
			});
		}
		// When the module is disposed, remove the <style> tags
		module.hot.dispose(function() { update(); });
	}

/***/ }),
/* 45 */
/***/ (function(module, exports, __webpack_require__) {

	exports = module.exports = __webpack_require__(36)();
	// imports
	exports.i(__webpack_require__(46), undefined);
	
	// module
	exports.push([module.id, "._3Ue4q58Ya6q2FCTVkZKllk {\n}\n", ""]);
	
	// exports
	exports.locals = {
		"typeRef": "_3Ue4q58Ya6q2FCTVkZKllk " + __webpack_require__(46).locals["typeLink"] + ""
	};

/***/ }),
/* 46 */
/***/ (function(module, exports, __webpack_require__) {

	exports = module.exports = __webpack_require__(36)();
	// imports
	
	
	// module
	exports.push([module.id, "html::-webkit-scrollbar\n{\n    width: 12px;\n    background-color: #f1f1f1;\n}\n\nhtml::-webkit-scrollbar-thumb\n{\n    border-radius: 10px;\n    -webkit-box-shadow: inset 0 0 6px rgba(0, 0, 0, .3);\n    background-color: #d0d0d0;\n}\n\n._3_QndMLrl0DS7txXsKk5aM {\n    color: #5b2699;\n}\n\n._1QSb_Lywz03jNMCELm-GrU {\n    padding-right: 8px;\n    padding-right: 0.5rem;\n    white-space: nowrap;\n    vertical-align: top;\n    font-family: monospace;\n    font-size: 14.4px;\n    font-size: 0.9rem;\n}\n\n._3a5669pwdwJabgmbtJHumc {\n    line-height: 1.3;\n    color: #333;\n}\n\n._3a5669pwdwJabgmbtJHumc code {\n    font-size: 0.8em;\n    background: #ddd;\n    padding: 0.1em;\n}\n\n._3Xlbyq0Qo-JOAJLLx2z9-l {\n    color: #64381f;\n}\n\n.NgU4gHjdynLJU2YSbF4ic {\n    color: #836c28;\n}\n\n._15sahXcXCjIULC63jwKqZE {\n    color: #007400;\n    text-decoration: none;\n}\n\n._1ssUqN390ygEtVlxHSnU0e,\n._1ssUqN390ygEtVlxHSnU0e:active,\n._1ssUqN390ygEtVlxHSnU0e:hover,\n._1ssUqN390ygEtVlxHSnU0e:visited {\n    color: #007400;\n    text-decoration: none;\n    font-family: monospace;\n    font-size: 14.4px;\n    font-size: 0.9rem;\n}\n", ""]);
	
	// exports
	exports.locals = {
		"argumentName": "_3_QndMLrl0DS7txXsKk5aM",
		"argumentCell": "_1QSb_Lywz03jNMCELm-GrU",
		"argumentRow": "_3a5669pwdwJabgmbtJHumc",
		"fieldName": "_3Xlbyq0Qo-JOAJLLx2z9-l",
		"defaultValue": "NgU4gHjdynLJU2YSbF4ic",
		"typeName": "_15sahXcXCjIULC63jwKqZE",
		"typeLink": "_1ssUqN390ygEtVlxHSnU0e"
	};

/***/ }),
/* 47 */
/***/ (function(module, exports, __webpack_require__) {

	// style-loader: Adds some css to the DOM by adding a <style> tag
	
	// load the styles
	var content = __webpack_require__(48);
	if(typeof content === 'string') content = [[module.id, content, '']];
	// add the styles to the DOM
	var update = __webpack_require__(37)(content, {});
	if(content.locals) module.exports = content.locals;
	// Hot Module Replacement
	if(false) {
		// When the styles change, update the <style> tags
		if(!content.locals) {
			module.hot.accept("!!../../node_modules/css-loader/index.js?modules&importLoaders=1!../../node_modules/postcss-loader/index.js!./FieldSyntaxView.css", function() {
				var newContent = require("!!../../node_modules/css-loader/index.js?modules&importLoaders=1!../../node_modules/postcss-loader/index.js!./FieldSyntaxView.css");
				if(typeof newContent === 'string') newContent = [[module.id, newContent, '']];
				update(newContent);
			});
		}
		// When the module is disposed, remove the <style> tags
		module.hot.dispose(function() { update(); });
	}

/***/ }),
/* 48 */
/***/ (function(module, exports, __webpack_require__) {

	exports = module.exports = __webpack_require__(36)();
	// imports
	exports.i(__webpack_require__(46), undefined);
	
	// module
	exports.push([module.id, "._3Q9rTqv61jz1TMbQgSC21Y {\n    margin-bottom: 11.2px;\n    margin-bottom: 0.7rem;\n    font-family: monospace;\n    background: #f0f0f9;\n    padding: 8px;\n    padding: 0.5rem;\n    font-size: 14.4px;\n    font-size: 0.9rem;\n    border-bottom: 1px solid #ddd;\n}\n\n.pfwgw1KVkaL-Jspb7XsLn {\n}\n\n._3qTEJI-SGaaBwcproq96Z9 {\n}\n\n._1C3jrn92-2_teD3Q_-WwDn {\n}\n", ""]);
	
	// exports
	exports.locals = {
		"container": "_3Q9rTqv61jz1TMbQgSC21Y",
		"name": "pfwgw1KVkaL-Jspb7XsLn " + __webpack_require__(46).locals["fieldName"] + "",
		"argumentName": "_3qTEJI-SGaaBwcproq96Z9 " + __webpack_require__(46).locals["argumentName"] + "",
		"defaultValue": "_1C3jrn92-2_teD3Q_-WwDn " + __webpack_require__(46).locals["defaultValue"] + ""
	};

/***/ }),
/* 49 */
/***/ (function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	    value: true
	});
	exports.FieldArgumentsTableView = undefined;
	
	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();
	
	var _react = __webpack_require__(1);
	
	var _react2 = _interopRequireDefault(_react);
	
	var _model = __webpack_require__(29);
	
	var _TypeRefView = __webpack_require__(43);
	
	var _DescriptionView = __webpack_require__(32);
	
	var _FieldArgumentsTableView = __webpack_require__(50);
	
	var StyleSheet = _interopRequireWildcard(_FieldArgumentsTableView);
	
	function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }
	
	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
	
	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
	
	function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }
	
	function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }
	
	var FieldArgumentsTableView = exports.FieldArgumentsTableView = function (_React$Component) {
	    _inherits(FieldArgumentsTableView, _React$Component);
	
	    function FieldArgumentsTableView() {
	        _classCallCheck(this, FieldArgumentsTableView);
	
	        return _possibleConstructorReturn(this, (FieldArgumentsTableView.__proto__ || Object.getPrototypeOf(FieldArgumentsTableView)).apply(this, arguments));
	    }
	
	    _createClass(FieldArgumentsTableView, [{
	        key: 'render',
	        value: function render() {
	            var _this2 = this;
	
	            var withDescription = this.props.args.filter(function (a) {
	                return a.description;
	            });
	
	            if (!withDescription.length) {
	                return null;
	            }
	
	            return _react2.default.createElement(
	                'table',
	                { className: StyleSheet.descriptionTable },
	                _react2.default.createElement(
	                    'thead',
	                    null,
	                    _react2.default.createElement(
	                        'tr',
	                        null,
	                        _react2.default.createElement(
	                            'th',
	                            {
	                                colSpan: '2',
	                                className: StyleSheet.header
	                            },
	                            'Arguments'
	                        )
	                    )
	                ),
	                _react2.default.createElement(
	                    'tbody',
	                    null,
	                    withDescription.map(function (a) {
	                        return _this2.renderRow(a);
	                    })
	                )
	            );
	        }
	    }, {
	        key: 'renderRow',
	        value: function renderRow(arg) {
	            return _react2.default.createElement(
	                'tr',
	                { key: arg.name, className: StyleSheet.row },
	                _react2.default.createElement(
	                    'td',
	                    {
	                        className: StyleSheet.key
	                    },
	                    _react2.default.createElement(
	                        'span',
	                        { className: StyleSheet.argumentName },
	                        arg.name
	                    ),
	                    ': ',
	                    _react2.default.createElement(_TypeRefView.TypeRefView, { typeRef: arg.type })
	                ),
	                _react2.default.createElement(
	                    'td',
	                    {
	                        className: StyleSheet.value
	                    },
	                    arg.description && _react2.default.createElement(_DescriptionView.DescriptionView, { description: arg.description })
	                )
	            );
	        }
	    }]);
	
	    return FieldArgumentsTableView;
	}(_react2.default.Component);

/***/ }),
/* 50 */
/***/ (function(module, exports, __webpack_require__) {

	// style-loader: Adds some css to the DOM by adding a <style> tag
	
	// load the styles
	var content = __webpack_require__(51);
	if(typeof content === 'string') content = [[module.id, content, '']];
	// add the styles to the DOM
	var update = __webpack_require__(37)(content, {});
	if(content.locals) module.exports = content.locals;
	// Hot Module Replacement
	if(false) {
		// When the styles change, update the <style> tags
		if(!content.locals) {
			module.hot.accept("!!../../node_modules/css-loader/index.js?modules&importLoaders=1!../../node_modules/postcss-loader/index.js!./FieldArgumentsTableView.css", function() {
				var newContent = require("!!../../node_modules/css-loader/index.js?modules&importLoaders=1!../../node_modules/postcss-loader/index.js!./FieldArgumentsTableView.css");
				if(typeof newContent === 'string') newContent = [[module.id, newContent, '']];
				update(newContent);
			});
		}
		// When the module is disposed, remove the <style> tags
		module.hot.dispose(function() { update(); });
	}

/***/ }),
/* 51 */
/***/ (function(module, exports, __webpack_require__) {

	exports = module.exports = __webpack_require__(36)();
	// imports
	exports.i(__webpack_require__(46), undefined);
	
	// module
	exports.push([module.id, "._2u0NKWFUVO10_7zl5FH1bX, ._3fZn7jWVOIpol-tdacvUco {\n    margin-top: 16px;\n    margin-top: 1rem;\n    width: 100%;\n    padding: 0;\n    border: 1px solid #d9d9d9;\n    border-collapse: collapse;\n}\n._3fZn7jWVOIpol-tdacvUco {\n    margin-left: 32px;\n    margin-left: 2rem;\n    width: calc(100% - 2rem);\n}\n\n._3fZn7jWVOIpol-tdacvUco td, ._3fZn7jWVOIpol-tdacvUco th, ._2u0NKWFUVO10_7zl5FH1bX td, ._2u0NKWFUVO10_7zl5FH1bX th {\n    padding: 8px;\n    padding: 0.5rem;\n}\n\n._3fZn7jWVOIpol-tdacvUco tbody tr:nth-child(even), ._2u0NKWFUVO10_7zl5FH1bX tbody tr:nth-child(even) {\n  background-color: #f2f2f2;\n}\n\n._14Noc9w-o_IUonJxsVOnBQ {\n    text-align: left;\n    font-size: 16px;\n    font-size: 1rem;\n    background: #f0f0f0;\n    border-bottom: 1px solid #d9d9d9;\n    font-feature-settings: \"c2sc\";\n    font-variant: small-caps;\n    text-transform: uppercase;\n    font-weight: bold;\n    color: #4a4a4a;\n}\n\n._3qzzdu41HzTOjXefzRE8dy {\n}\n\n._3g8_wlJYIQqfvRx4Tdzt4u {\n    width: 100%;\n}\n\n._1XONXofpDzZZq1kxZDtU2p {\n}\n\n.Sb22PNqbe2ZV1oFtChBAD {\n}\n", ""]);
	
	// exports
	exports.locals = {
		"table": "_2u0NKWFUVO10_7zl5FH1bX",
		"descriptionTable": "_3fZn7jWVOIpol-tdacvUco",
		"header": "_14Noc9w-o_IUonJxsVOnBQ",
		"key": "_3qzzdu41HzTOjXefzRE8dy " + __webpack_require__(46).locals["argumentCell"] + "",
		"value": "_3g8_wlJYIQqfvRx4Tdzt4u",
		"row": "_1XONXofpDzZZq1kxZDtU2p " + __webpack_require__(46).locals["argumentRow"] + "",
		"argumentName": "Sb22PNqbe2ZV1oFtChBAD " + __webpack_require__(46).locals["argumentName"] + ""
	};

/***/ }),
/* 52 */
/***/ (function(module, exports, __webpack_require__) {

	// style-loader: Adds some css to the DOM by adding a <style> tag
	
	// load the styles
	var content = __webpack_require__(53);
	if(typeof content === 'string') content = [[module.id, content, '']];
	// add the styles to the DOM
	var update = __webpack_require__(37)(content, {});
	if(content.locals) module.exports = content.locals;
	// Hot Module Replacement
	if(false) {
		// When the styles change, update the <style> tags
		if(!content.locals) {
			module.hot.accept("!!../../node_modules/css-loader/index.js?modules&importLoaders=1!../../node_modules/postcss-loader/index.js!./FieldView.css", function() {
				var newContent = require("!!../../node_modules/css-loader/index.js?modules&importLoaders=1!../../node_modules/postcss-loader/index.js!./FieldView.css");
				if(typeof newContent === 'string') newContent = [[module.id, newContent, '']];
				update(newContent);
			});
		}
		// When the module is disposed, remove the <style> tags
		module.hot.dispose(function() { update(); });
	}

/***/ }),
/* 53 */
/***/ (function(module, exports, __webpack_require__) {

	exports = module.exports = __webpack_require__(36)();
	// imports
	
	
	// module
	exports.push([module.id, "._2CI__araY4C94OAnkGP8Fv {\n    margin-bottom: 8px;\n    margin-bottom: 0.5rem;\n    margin-bottom: 16px;\n    margin-bottom: 1rem;\n    color: #333;\n}\n\n._158AUimPZVUE217-1MuDQx {\n    margin-left: 32px;\n    margin-left: 2rem;\n}\n\n._158AUimPZVUE217-1MuDQx p {\n    margin-top: 0;\n}\n\n.Wbz0ueEU3TmlKLEUdOGVP {\n    font-weight: bold;\n    color: crimson;\n}\n\n.Wbz0ueEU3TmlKLEUdOGVP p {\n    margin-top: 0;\n}", ""]);
	
	// exports
	exports.locals = {
		"container": "_2CI__araY4C94OAnkGP8Fv",
		"description": "_158AUimPZVUE217-1MuDQx",
		"deprecated": "Wbz0ueEU3TmlKLEUdOGVP"
	};

/***/ }),
/* 54 */
/***/ (function(module, exports, __webpack_require__) {

	// style-loader: Adds some css to the DOM by adding a <style> tag
	
	// load the styles
	var content = __webpack_require__(55);
	if(typeof content === 'string') content = [[module.id, content, '']];
	// add the styles to the DOM
	var update = __webpack_require__(37)(content, {});
	if(content.locals) module.exports = content.locals;
	// Hot Module Replacement
	if(false) {
		// When the styles change, update the <style> tags
		if(!content.locals) {
			module.hot.accept("!!../../node_modules/css-loader/index.js?modules&importLoaders=1!../../node_modules/postcss-loader/index.js!./TypeDocsViews.css", function() {
				var newContent = require("!!../../node_modules/css-loader/index.js?modules&importLoaders=1!../../node_modules/postcss-loader/index.js!./TypeDocsViews.css");
				if(typeof newContent === 'string') newContent = [[module.id, newContent, '']];
				update(newContent);
			});
		}
		// When the module is disposed, remove the <style> tags
		module.hot.dispose(function() { update(); });
	}

/***/ }),
/* 55 */
/***/ (function(module, exports, __webpack_require__) {

	exports = module.exports = __webpack_require__(36)();
	// imports
	exports.i(__webpack_require__(46), undefined);
	
	// module
	exports.push([module.id, "._31nGuA4VcO5ASJ1Y-50NC0 {\n    margin-bottom: 20px;\n}\n\n._31nGuA4VcO5ASJ1Y-50NC0 pre {\n    width: 100%;\n    padding: 16px 0;\n    padding:1rem 0;\n    border: 1px solid #e8e8e8;\n    background: #f0f0f0;\n    font-size: 14.4px;\n    font-size: 0.9rem;\n\n}\n._1hBwBkrQ8ZlOyOUcLvjRpt {\n    margin: 48px 0 32px 0;\n    margin: 3rem 0 2rem 0;\n}\n\n._1gsHTtZCfZy0kwT90S9nZC {\n    font-feature-settings: \"c2sc\";\n    font-variant: small-caps;\n    text-transform: uppercase;\n    font-weight: bold;\n    color: #4a4a4a;\n    border-bottom: 1px solid #d9d9d9;\n    margin-top: 16px;\n    margin-top: 1rem;\n    margin-bottom: 8px;\n    margin-bottom: 0.5rem;\n}\n\n._2rkCQUiZ63eNMyTCRDL7GX {\n    list-style: none;\n    margin: 0;\n    padding: 0;\n}\n\n.hI41jTQ51eUSGSCTegJoD {\n}\n.gfgIAL-qhYjEMYBS3uxtp {\n    color: crimson;\n    text-decoration: line-through;\n}\n\n.bHFx-gWNy1lALB9MKGx6U {\n}\n", ""]);
	
	// exports
	exports.locals = {
		"type": "_31nGuA4VcO5ASJ1Y-50NC0",
		"heading": "_1hBwBkrQ8ZlOyOUcLvjRpt",
		"subHeading": "_1gsHTtZCfZy0kwT90S9nZC",
		"interfacesList": "_2rkCQUiZ63eNMyTCRDL7GX",
		"enumName": "hI41jTQ51eUSGSCTegJoD " + __webpack_require__(46).locals["argumentName"] + " " + __webpack_require__(46).locals["argumentCell"] + "",
		"enumNameDeprecated": "gfgIAL-qhYjEMYBS3uxtp " + __webpack_require__(46).locals["argumentName"] + " " + __webpack_require__(46).locals["argumentCell"] + "",
		"enumRow": "bHFx-gWNy1lALB9MKGx6U " + __webpack_require__(46).locals["argumentRow"] + ""
	};

/***/ }),
/* 56 */
/***/ (function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	    value: true
	});
	
	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();
	
	var _react = __webpack_require__(1);
	
	var _react2 = _interopRequireDefault(_react);
	
	var _SectionView = __webpack_require__(57);
	
	var StyleSheet = _interopRequireWildcard(_SectionView);
	
	function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }
	
	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
	
	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
	
	function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }
	
	function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }
	
	var SectionView = function (_React$Component) {
	    _inherits(SectionView, _React$Component);
	
	    function SectionView() {
	        _classCallCheck(this, SectionView);
	
	        return _possibleConstructorReturn(this, (SectionView.__proto__ || Object.getPrototypeOf(SectionView)).apply(this, arguments));
	    }
	
	    _createClass(SectionView, [{
	        key: 'render',
	        value: function render() {
	            return _react2.default.createElement(
	                'div',
	                { className: StyleSheet.section },
	                _react2.default.createElement('a', { name: this.props.name }),
	                _react2.default.createElement(
	                    'h2',
	                    null,
	                    this.props.name
	                ),
	                this.props.items.map(function (item) {
	                    return item.component;
	                })
	            );
	        }
	    }]);
	
	    return SectionView;
	}(_react2.default.Component);
	
	exports.default = SectionView;

/***/ }),
/* 57 */
/***/ (function(module, exports, __webpack_require__) {

	// style-loader: Adds some css to the DOM by adding a <style> tag
	
	// load the styles
	var content = __webpack_require__(58);
	if(typeof content === 'string') content = [[module.id, content, '']];
	// add the styles to the DOM
	var update = __webpack_require__(37)(content, {});
	if(content.locals) module.exports = content.locals;
	// Hot Module Replacement
	if(false) {
		// When the styles change, update the <style> tags
		if(!content.locals) {
			module.hot.accept("!!../../node_modules/css-loader/index.js?modules&importLoaders=1!../../node_modules/postcss-loader/index.js!./SectionView.css", function() {
				var newContent = require("!!../../node_modules/css-loader/index.js?modules&importLoaders=1!../../node_modules/postcss-loader/index.js!./SectionView.css");
				if(typeof newContent === 'string') newContent = [[module.id, newContent, '']];
				update(newContent);
			});
		}
		// When the module is disposed, remove the <style> tags
		module.hot.dispose(function() { update(); });
	}

/***/ }),
/* 58 */
/***/ (function(module, exports, __webpack_require__) {

	exports = module.exports = __webpack_require__(36)();
	// imports
	exports.i(__webpack_require__(59), "");
	
	// module
	exports.push([module.id, ".L1v8qWjjMTDbscwjQgB_s {\n    padding: 10px 0;\n}\n\nh2 {\n\t\ttext-transform: uppercase;\n\t\tborder-bottom: 2px solid;\n\t\tmargin-bottom: 48px;\n\t\tmargin-bottom: 3rem;\n\t\tpadding-bottom: 8px;\n\t\tpadding-bottom: 0.5rem;\n}", ""]);
	
	// exports
	exports.locals = {
		"section": "L1v8qWjjMTDbscwjQgB_s"
	};

/***/ }),
/* 59 */
/***/ (function(module, exports, __webpack_require__) {

	exports = module.exports = __webpack_require__(36)();
	// imports
	
	
	// module
	exports.push([module.id, "/*! normalize.css v4.1.1 | MIT License | github.com/necolas/normalize.css */\n\n* {\n  box-sizing: border-box;\n}\n\n/**\n * 1. Change the default font family in all browsers (opinionated).\n * 2. Prevent adjustments of font size after orientation changes in IE and iOS.\n */\n\nhtml {\n  font-family: -apple-system, BlinkMacSystemFont,\n    \"Segoe UI\", \"Roboto\", \"Oxygen\", \"Ubuntu\", \"Cantarell\",\n    \"Fira Sans\", \"Droid Sans\", \"Helvetica Neue\",\n    sans-serif; /* 1 */\n  -ms-text-size-adjust: 100%; /* 2 */\n  -webkit-text-size-adjust: 100%; /* 2 */\n}\n\n/**\n * Remove the margin in all browsers (opinionated).\n */\n\nbody {\n  margin: 0 8px;\n}\n\n/* HTML5 display definitions\n   ========================================================================== */\n\n/**\n * Add the correct display in IE 9-.\n * 1. Add the correct display in Edge, IE, and Firefox.\n * 2. Add the correct display in IE.\n */\n\narticle,\naside,\ndetails, /* 1 */\nfigcaption,\nfigure,\nfooter,\nheader,\nmain, /* 2 */\nmenu,\nnav,\nsection,\nsummary { /* 1 */\n  display: block;\n}\n\n/**\n * Add the correct display in IE 9-.\n */\n\naudio,\ncanvas,\nprogress,\nvideo {\n  display: inline-block;\n}\n\n/**\n * Add the correct display in iOS 4-7.\n */\n\naudio:not([controls]) {\n  display: none;\n  height: 0;\n}\n\n/**\n * Add the correct vertical alignment in Chrome, Firefox, and Opera.\n */\n\nprogress {\n  vertical-align: baseline;\n}\n\n/**\n * Add the correct display in IE 10-.\n * 1. Add the correct display in IE.\n */\n\ntemplate, /* 1 */\n[hidden] {\n  display: none;\n}\n\n/* Links\n   ========================================================================== */\n\n/**\n * 1. Remove the gray background on active links in IE 10.\n * 2. Remove gaps in links underline in iOS 8+ and Safari 8+.\n */\n\na {\n  background-color: transparent; /* 1 */\n   -webkit-text-decoration-skip: ink;  /* 2 */\n}\n\n/**\n * Remove the outline on focused links when they are also active or hovered\n * in all browsers (opinionated).\n */\n\na:active,\na:hover {\n  outline-width: 0;\n}\n\n/* Text-level semantics\n   ========================================================================== */\n\n/**\n * 1. Remove the bottom border in Firefox 39-.\n * 2. Add the correct text decoration in Chrome, Edge, IE, Opera, and Safari.\n */\n\nabbr[title] {\n  border-bottom: none; /* 1 */\n  text-decoration: underline; /* 2 */\n  text-decoration: underline dotted; /* 2 */\n}\n\n/**\n * Prevent the duplicate application of `bolder` by the next rule in Safari 6.\n */\n\nb,\nstrong {\n  font-weight: inherit;\n}\n\n/**\n * Add the correct font weight in Chrome, Edge, and Safari.\n */\n\nb,\nstrong {\n  font-weight: bolder;\n}\n\n/**\n * Add the correct font style in Android 4.3-.\n */\n\ndfn {\n  font-style: italic;\n}\n\n/**\n * Correct the font size and margin on `h1` elements within `section` and\n * `article` contexts in Chrome, Firefox, and Safari.\n */\n\nh1 {\n  font-size: 2em;\n  margin: 0.67em 0;\n}\n\n/**\n * Add the correct background and color in IE 9-.\n */\n\nmark {\n  background-color: #ff0;\n  color: #000;\n}\n\n/**\n * Add the correct font size in all browsers.\n */\n\nsmall {\n  font-size: 80%;\n}\n\n/**\n * Prevent `sub` and `sup` elements from affecting the line height in\n * all browsers.\n */\n\nsub,\nsup {\n  font-size: 75%;\n  line-height: 0;\n  position: relative;\n  vertical-align: baseline;\n}\n\nsub {\n  bottom: -0.25em;\n}\n\nsup {\n  top: -0.5em;\n}\n\n/* Embedded content\n   ========================================================================== */\n\n/**\n * Remove the border on images inside links in IE 10-.\n */\n\nimg {\n  border-style: none;\n}\n\n/**\n * Hide the overflow in IE.\n */\n\nsvg:not(:root) {\n  overflow: hidden;\n}\n\n/* Grouping content\n   ========================================================================== */\n\n/**\n * 1. Correct the inheritance and scaling of font size in all browsers.\n * 2. Correct the odd `em` font sizing in all browsers.\n */\n\ncode,\nkbd,\npre,\nsamp {\n  font-family: monospace, monospace; /* 1 */\n  font-size: 1em; /* 2 */\n}\n\n/**\n * Add the correct margin in IE 8.\n */\n\nfigure {\n  margin: 1em 40px;\n}\n\n/**\n * 1. Add the correct box sizing in Firefox.\n * 2. Show the overflow in Edge and IE.\n */\n\nhr {\n  box-sizing: content-box; /* 1 */\n  height: 0; /* 1 */\n  overflow: visible; /* 2 */\n}\n\n/* Forms\n   ========================================================================== */\n\n/**\n * 1. Change font properties to `inherit` in all browsers (opinionated).\n * 2. Remove the margin in Firefox and Safari.\n */\n\nbutton,\ninput,\noptgroup,\nselect,\ntextarea {\n  font: inherit; /* 1 */\n  margin: 0; /* 2 */\n}\n\n/**\n * Restore the font weight unset by the previous rule.\n */\n\noptgroup {\n  font-weight: bold;\n}\n\n/**\n * Show the overflow in IE.\n * 1. Show the overflow in Edge.\n */\n\nbutton,\ninput { /* 1 */\n  overflow: visible;\n}\n\n/**\n * Remove the inheritance of text transform in Edge, Firefox, and IE.\n * 1. Remove the inheritance of text transform in Firefox.\n */\n\nbutton,\nselect { /* 1 */\n  text-transform: none;\n}\n\n/**\n * 1. Prevent a WebKit bug where (2) destroys native `audio` and `video`\n *    controls in Android 4.\n * 2. Correct the inability to style clickable types in iOS and Safari.\n */\n\nbutton,\nhtml [type=\"button\"], /* 1 */\n[type=\"reset\"],\n[type=\"submit\"] {\n  -webkit-appearance: button; /* 2 */\n}\n\n/**\n * Remove the inner border and padding in Firefox.\n */\n\nbutton::-moz-focus-inner,\n[type=\"button\"]::-moz-focus-inner,\n[type=\"reset\"]::-moz-focus-inner,\n[type=\"submit\"]::-moz-focus-inner {\n  border-style: none;\n  padding: 0;\n}\n\n/**\n * Restore the focus styles unset by the previous rule.\n */\n\nbutton:-moz-focusring,\n[type=\"button\"]:-moz-focusring,\n[type=\"reset\"]:-moz-focusring,\n[type=\"submit\"]:-moz-focusring {\n  outline: 1px dotted ButtonText;\n}\n\n/**\n * Change the border, margin, and padding in all browsers (opinionated).\n */\n\nfieldset {\n  border: 1px solid #c0c0c0;\n  margin: 0 2px;\n  padding: 0.35em 0.625em 0.75em;\n}\n\n/**\n * 1. Correct the text wrapping in Edge and IE.\n * 2. Correct the color inheritance from `fieldset` elements in IE.\n * 3. Remove the padding so developers are not caught out when they zero out\n *    `fieldset` elements in all browsers.\n */\n\nlegend {\n  box-sizing: border-box; /* 1 */\n  color: inherit; /* 2 */\n  display: table; /* 1 */\n  max-width: 100%; /* 1 */\n  padding: 0; /* 3 */\n  white-space: normal; /* 1 */\n}\n\n/**\n * Remove the default vertical scrollbar in IE.\n */\n\ntextarea {\n  overflow: auto;\n}\n\n/**\n * 1. Add the correct box sizing in IE 10-.\n * 2. Remove the padding in IE 10-.\n */\n\n[type=\"checkbox\"],\n[type=\"radio\"] {\n  box-sizing: border-box; /* 1 */\n  padding: 0; /* 2 */\n}\n\n/**\n * Correct the cursor style of increment and decrement buttons in Chrome.\n */\n\n[type=\"number\"]::-webkit-inner-spin-button,\n[type=\"number\"]::-webkit-outer-spin-button {\n  height: auto;\n}\n\n/**\n * 1. Correct the odd appearance in Chrome and Safari.\n * 2. Correct the outline style in Safari.\n */\n\n[type=\"search\"] {\n  -webkit-appearance: textfield; /* 1 */\n  outline-offset: -2px; /* 2 */\n}\n\n/**\n * Remove the inner padding and cancel buttons in Chrome and Safari on OS X.\n */\n\n[type=\"search\"]::-webkit-search-cancel-button,\n[type=\"search\"]::-webkit-search-decoration {\n  -webkit-appearance: none;\n}\n\n/**\n * Correct the text style of placeholders in Chrome, Edge, and Safari.\n */\n\n::-webkit-input-placeholder {\n  color: inherit;\n  opacity: 0.54;\n}\n\n/**\n * 1. Correct the inability to style clickable types in iOS and Safari.\n * 2. Change font properties to `inherit` in Safari.\n */\n\n::-webkit-file-upload-button {\n  -webkit-appearance: button; /* 1 */\n  font: inherit; /* 2 */\n}\n", ""]);
	
	// exports


/***/ }),
/* 60 */
/***/ (function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	    value: true
	});
	
	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();
	
	var _react = __webpack_require__(1);
	
	var _react2 = _interopRequireDefault(_react);
	
	var _SideNavSectionView = __webpack_require__(61);
	
	var StyleSheet = _interopRequireWildcard(_SideNavSectionView);
	
	function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }
	
	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
	
	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
	
	function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }
	
	function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }
	
	var SideNavSectionView = function (_React$Component) {
	    _inherits(SideNavSectionView, _React$Component);
	
	    function SideNavSectionView() {
	        _classCallCheck(this, SideNavSectionView);
	
	        return _possibleConstructorReturn(this, (SideNavSectionView.__proto__ || Object.getPrototypeOf(SideNavSectionView)).apply(this, arguments));
	    }
	
	    _createClass(SideNavSectionView, [{
	        key: 'render',
	        value: function render() {
	            return _react2.default.createElement(
	                'div',
	                { className: StyleSheet.sidenavSection },
	                _react2.default.createElement(
	                    'div',
	                    { className: StyleSheet.sectionLink },
	                    _react2.default.createElement(
	                        'a',
	                        { href: '#' + this.props.name },
	                        this.props.name
	                    )
	                ),
	                this.props.items.map(function (item) {
	                    return _react2.default.createElement(
	                        'div',
	                        { className: StyleSheet.typeLink },
	                        _react2.default.createElement(
	                            'a',
	                            { href: '#' + item.name },
	                            '\xA0\xA0',
	                            item.name
	                        )
	                    );
	                })
	            );
	        }
	    }]);
	
	    return SideNavSectionView;
	}(_react2.default.Component);
	
	exports.default = SideNavSectionView;

/***/ }),
/* 61 */
/***/ (function(module, exports, __webpack_require__) {

	// style-loader: Adds some css to the DOM by adding a <style> tag
	
	// load the styles
	var content = __webpack_require__(62);
	if(typeof content === 'string') content = [[module.id, content, '']];
	// add the styles to the DOM
	var update = __webpack_require__(37)(content, {});
	if(content.locals) module.exports = content.locals;
	// Hot Module Replacement
	if(false) {
		// When the styles change, update the <style> tags
		if(!content.locals) {
			module.hot.accept("!!../../node_modules/css-loader/index.js?modules&importLoaders=1!../../node_modules/postcss-loader/index.js!./SideNavSectionView.css", function() {
				var newContent = require("!!../../node_modules/css-loader/index.js?modules&importLoaders=1!../../node_modules/postcss-loader/index.js!./SideNavSectionView.css");
				if(typeof newContent === 'string') newContent = [[module.id, newContent, '']];
				update(newContent);
			});
		}
		// When the module is disposed, remove the <style> tags
		module.hot.dispose(function() { update(); });
	}

/***/ }),
/* 62 */
/***/ (function(module, exports, __webpack_require__) {

	exports = module.exports = __webpack_require__(36)();
	// imports
	exports.i(__webpack_require__(59), "");
	
	// module
	exports.push([module.id, "._1xGW5JKJn4TysMIRtV4bNC {\n    width: 100%;\n}\n\n._2MbtXVBhy0ow1PGFq442II,\n._1wz12CHPOX1ElLLZ7I3avj {\n    width: 100%;\n}\n\n._2MbtXVBhy0ow1PGFq442II > a,\n._1wz12CHPOX1ElLLZ7I3avj > a {\n    display: block;\n    width: 100%;\n    padding: 7px 5px;\n    text-decoration: none;\n    color: dimgray;\n}\n\n._2MbtXVBhy0ow1PGFq442II > a {\n    text-transform: uppercase;\n    color: #333;\n    font-weight: bold;\n}\n\n._1wz12CHPOX1ElLLZ7I3avj:hover,\n._2MbtXVBhy0ow1PGFq442II:hover {\n    background: lightgray;\n}", ""]);
	
	// exports
	exports.locals = {
		"sidenavSection": "_1xGW5JKJn4TysMIRtV4bNC",
		"sectionLink": "_2MbtXVBhy0ow1PGFq442II",
		"typeLink": "_1wz12CHPOX1ElLLZ7I3avj"
	};

/***/ }),
/* 63 */
/***/ (function(module, exports, __webpack_require__) {

	// style-loader: Adds some css to the DOM by adding a <style> tag
	
	// load the styles
	var content = __webpack_require__(64);
	if(typeof content === 'string') content = [[module.id, content, '']];
	// add the styles to the DOM
	var update = __webpack_require__(37)(content, {});
	if(content.locals) module.exports = content.locals;
	// Hot Module Replacement
	if(false) {
		// When the styles change, update the <style> tags
		if(!content.locals) {
			module.hot.accept("!!../../node_modules/css-loader/index.js?modules&importLoaders=1!../../node_modules/postcss-loader/index.js!./SchemaDocsView.css", function() {
				var newContent = require("!!../../node_modules/css-loader/index.js?modules&importLoaders=1!../../node_modules/postcss-loader/index.js!./SchemaDocsView.css");
				if(typeof newContent === 'string') newContent = [[module.id, newContent, '']];
				update(newContent);
			});
		}
		// When the module is disposed, remove the <style> tags
		module.hot.dispose(function() { update(); });
	}

/***/ }),
/* 64 */
/***/ (function(module, exports, __webpack_require__) {

	exports = module.exports = __webpack_require__(36)();
	// imports
	exports.i(__webpack_require__(59), "");
	
	// module
	exports.push([module.id, "._2Wa9wu-awiDVZ9IXTPcyFt {\n    height: 100vh;\n}\n\n._38MtHDcUga2pYTxIRJJZ8o {\n}\n\n._2g11fbDuD18M7-sHGYuAfi {\n    display: -ms-flexbox;\n    display: flex;\n    -ms-flex-pack: center;\n        justify-content: center;\n    margin-left: 270px;\n}\n\n._8ogFihsx3UFu7jnisJFQh {\n    position: fixed;\n    overflow-y: scroll;\n    top: 0;\n    bottom: 0;\n    left: 0;\n    width: 250px;\n    background: #f0f0f0;\n}\n._8ogFihsx3UFu7jnisJFQh::-webkit-scrollbar\n{\n    width: 12px;\n    background-color: #f1f1f1;\n}\n\n._8ogFihsx3UFu7jnisJFQh::-webkit-scrollbar-thumb\n{\n    border-radius: 10px;\n    -webkit-box-shadow: inset 0 0 6px rgba(0, 0, 0, .3);\n    background-color: #d0d0d0;\n}\n@media only screen and (max-width: 767px) {\n    ._8ogFihsx3UFu7jnisJFQh {\n        display: none;\n    }\n    ._2g11fbDuD18M7-sHGYuAfi {\n        margin-left: 0px;\n        display: block;\n    }\n}\n._3LliCFvyD_zfkKsrqSHqky {\n    display: block;\n    border-radius: 10px;\n    border: 2px solid darkgray;\n    color: darkgray;\n    width: 220px;\n    font-size: 16px;\n    font-size: 1rem;\n    padding: 10px;\n    margin: 20px 10px 0 10px;\n}\n\n._3LliCFvyD_zfkKsrqSHqky:hover,\n._3LliCFvyD_zfkKsrqSHqky:focus\n{\n    outline: none;\n}\n\n._3UYhBB4Rkyjb1nRvUGQPGD {\n    list-style: none;\n    margin:0;\n    padding:0;\n}\n\n._2DORhY6kDat0gOnScCJ4kz {\n    padding: 3px 3px 3px 18px;\n    width: 100%;\n}\n\n._2DORhY6kDat0gOnScCJ4kz:hover {\n    background: lightgray;\n}\n\n._2DORhY6kDat0gOnScCJ4kz > a {\n    display: block;\n    width: 100%;\n    color: darkgray;\n    text-decoration: none;\n    padding: 3px;\n}\n\n._3EiuFTC5cjTgHZ9HNaG1AS {\n    background: lightgray;\n}", ""]);
	
	// exports
	exports.locals = {
		"wrapper": "_2Wa9wu-awiDVZ9IXTPcyFt",
		"container": "_38MtHDcUga2pYTxIRJJZ8o",
		"content": "_2g11fbDuD18M7-sHGYuAfi",
		"sidenav": "_8ogFihsx3UFu7jnisJFQh",
		"selectInput": "_3LliCFvyD_zfkKsrqSHqky",
		"selectList": "_3UYhBB4Rkyjb1nRvUGQPGD",
		"selectItem": "_2DORhY6kDat0gOnScCJ4kz",
		"selectHover": "_3EiuFTC5cjTgHZ9HNaG1AS"
	};

/***/ }),
/* 65 */
/***/ (function(module, exports) {

	module.exports = "query IntrospectionQuery {\n  __schema {\n    queryType {\n      name\n    }\n    mutationType {\n      name\n    }\n    subscriptionType {\n      name\n    }\n    types {\n      ...FullType\n    }\n    directives {\n      name\n      description\n      args {\n        ...InputValue\n      }\n      locations\n    }\n  }\n}\n\nfragment FullType on __Type {\n  kind\n  name\n  description\n  fields(includeDeprecated: true) {\n    name\n    description\n    args {\n      ...InputValue\n    }\n    type {\n      ...TypeRef\n    }\n    isDeprecated\n    deprecationReason\n  }\n  inputFields {\n    ...InputValue\n  }\n  interfaces {\n    ...TypeRef\n  }\n  enumValues(includeDeprecated: true) {\n    name\n    description\n    isDeprecated\n    deprecationReason\n  }\n  possibleTypes {\n    ...TypeRef\n  }\n}\n\nfragment InputValue on __InputValue {\n  name\n  description\n  type {\n    ...TypeRef\n  }\n  defaultValue\n}\n\nfragment TypeRef on __Type {\n  kind\n  name\n  ofType {\n    kind\n    name\n    ofType {\n      kind\n      name\n      ofType {\n        kind\n        name\n      }\n    }\n  }\n}\n\n"

/***/ })
/******/ ])
});
;
//# sourceMappingURL=graphql-docs.js.map