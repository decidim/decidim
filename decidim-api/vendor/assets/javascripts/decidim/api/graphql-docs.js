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
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	    value: true
	});
	exports.GraphQLDocs = undefined;
	
	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();
	
	var _react = __webpack_require__(1);
	
	var _react2 = _interopRequireDefault(_react);
	
	var _SchemaDocsView = __webpack_require__(2);
	
	var _model = __webpack_require__(3);
	
	var _introspectionQuery = __webpack_require__(30);
	
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

/***/ },
/* 1 */
/***/ function(module, exports) {

	module.exports = __WEBPACK_EXTERNAL_MODULE_1__;

/***/ },
/* 2 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	    value: true
	});
	exports.SchemaDocsView = undefined;
	
	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();
	
	var _react = __webpack_require__(1);
	
	var _react2 = _interopRequireDefault(_react);
	
	var _model = __webpack_require__(3);
	
	var _schemaWalker = __webpack_require__(4);
	
	var _TypeDocsViews = __webpack_require__(5);
	
	var _SchemaDocsView = __webpack_require__(27);
	
	var StyleSheet = _interopRequireWildcard(_SchemaDocsView);
	
	function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }
	
	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
	
	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
	
	function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }
	
	function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }
	
	var SchemaDocsView = exports.SchemaDocsView = function (_React$Component) {
	    _inherits(SchemaDocsView, _React$Component);
	
	    function SchemaDocsView() {
	        _classCallCheck(this, SchemaDocsView);
	
	        return _possibleConstructorReturn(this, (SchemaDocsView.__proto__ || Object.getPrototypeOf(SchemaDocsView)).apply(this, arguments));
	    }
	
	    _createClass(SchemaDocsView, [{
	        key: 'render',
	        value: function render() {
	            var _this2 = this;
	
	            var types = (0, _schemaWalker.getReferencesInSchema)(this.props.schema).map(function (tn) {
	                return _this2.props.schema.types[tn];
	            });
	            var components = [];
	
	            types.forEach(function (t) {
	                if (t instanceof _model.ObjectType) {
	                    components.push(_react2.default.createElement(_TypeDocsViews.ObjectDocsView, {
	                        key: t.name,
	                        type: t,
	                        titleOverride: _this2.titleOverrideFor(t)
	                    }));
	                }
	                if (t instanceof _model.InterfaceType) {
	                    components.push(_react2.default.createElement(_TypeDocsViews.InterfaceDocsView, {
	                        key: t.name,
	                        type: t
	                    }));
	                }
	                if (t instanceof _model.EnumType) {
	                    components.push(_react2.default.createElement(_TypeDocsViews.EnumDocsView, {
	                        key: t.name,
	                        type: t
	                    }));
	                }
	                if (t instanceof _model.InputObjectType) {
	                    components.push(_react2.default.createElement(_TypeDocsViews.InputObjectDocsView, {
	                        key: t.name,
	                        type: t
	                    }));
	                }
	            });
	            types.forEach(function (t) {
	                if (t instanceof _model.ScalarType) {
	                    components.push(_react2.default.createElement(_TypeDocsViews.ScalarDocsView, {
	                        key: t.name,
	                        type: t
	                    }));
	                }
	            });
	
	            return _react2.default.createElement(
	                'div',
	                { className: StyleSheet.wrapper },
	                _react2.default.createElement(
	                    'div',
	                    { className: StyleSheet.container },
	                    components
	                )
	            );
	        }
	    }, {
	        key: 'titleOverrideFor',
	        value: function titleOverrideFor(t) {
	            if (t === this.props.schema.getQueryType()) {
	                return 'Root query';
	            }
	            if (t === this.props.schema.getMutationType()) {
	                return 'Mutations';
	            }
	
	            return null;
	        }
	    }]);
	
	    return SchemaDocsView;
	}(_react2.default.Component);

/***/ },
/* 3 */
/***/ function(module, exports) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	    value: true
	});
	
	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();
	
	function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }
	
	function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }
	
	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
	
	var TYPE_KINDS = exports.TYPE_KINDS = ['SCALAR', 'INTERFACE', 'OBJECT', 'ENUM', 'INPUT_OBJECT'];
	
	var Schema = exports.Schema = function () {
	    function Schema(introspectionResult) {
	        var _this = this;
	
	        _classCallCheck(this, Schema);
	
	        if (!introspectionResult.__schema) {
	            throw new Error('Function "Schema" precondition failed: introspectionResult.__schema');
	        }
	
	        if (!Array.isArray(introspectionResult.__schema.types)) {
	            throw new Error('Function "Schema" precondition failed: Array.isArray(introspectionResult.__schema.types)');
	        }
	
	        if (!introspectionResult.__schema.queryType) {
	            throw new Error('Function "Schema" precondition failed: introspectionResult.__schema.queryType');
	        }
	
	        if (!(introspectionResult.__schema.mutationType === null || typeof introspectionResult.__schema.mutationType.name === 'string')) {
	            throw new Error('Function "Schema" precondition failed: introspectionResult.__schema.mutationType === null || typeof introspectionResult.__schema.mutationType.name === \'string\'');
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
	            } else {
	                throw new Error('Unsupported type kind: ' + introspectionType.kind);
	            }
	        }
	    }]);
	
	    function Type(introspectionType) {
	        _classCallCheck(this, Type);
	
	        if (!(this.constructor !== Type)) {
	            throw new Error('Function "Type" precondition failed: this.constructor !== Type');
	        }
	
	        if (!(typeof introspectionType.name === 'string')) {
	            throw new Error('Function "Type" precondition failed: typeof introspectionType.name === \'string\'');
	        }
	
	        if (!(introspectionType.description === null || typeof introspectionType.description === 'string')) {
	            throw new Error('Function "Type" precondition failed: introspectionType.description === null || typeof introspectionType.description === \'string\'');
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
	            throw new Error('Function "ObjectType" precondition failed: introspectionType.kind === \'OBJECT\'');
	        }
	
	        if (!Array.isArray(introspectionType.fields)) {
	            throw new Error('Function "ObjectType" precondition failed: Array.isArray(introspectionType.fields)');
	        }
	
	        if (!(introspectionType.interfaces === null || Array.isArray(introspectionType.interfaces))) {
	            throw new Error('Function "ObjectType" precondition failed: introspectionType.interfaces === null || Array.isArray(introspectionType.interfaces)');
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
	
	var ScalarType = exports.ScalarType = function (_Type2) {
	    _inherits(ScalarType, _Type2);
	
	    function ScalarType(introspectionType) {
	        _classCallCheck(this, ScalarType);
	
	        if (!(introspectionType.kind === 'SCALAR')) {
	            throw new Error('Function "ScalarType" precondition failed: introspectionType.kind === \'SCALAR\'');
	        }
	
	        return _possibleConstructorReturn(this, (ScalarType.__proto__ || Object.getPrototypeOf(ScalarType)).call(this, introspectionType));
	    }
	
	    return ScalarType;
	}(Type);
	
	var InterfaceType = exports.InterfaceType = function (_Type3) {
	    _inherits(InterfaceType, _Type3);
	
	    function InterfaceType(introspectionType) {
	        _classCallCheck(this, InterfaceType);
	
	        if (!(introspectionType.kind === 'INTERFACE')) {
	            throw new Error('Function "InterfaceType" precondition failed: introspectionType.kind === \'INTERFACE\'');
	        }
	
	        if (!Array.isArray(introspectionType.fields)) {
	            throw new Error('Function "InterfaceType" precondition failed: Array.isArray(introspectionType.fields)');
	        }
	
	        if (!Array.isArray(introspectionType.possibleTypes)) {
	            throw new Error('Function "InterfaceType" precondition failed: Array.isArray(introspectionType.possibleTypes)');
	        }
	
	        var _this4 = _possibleConstructorReturn(this, (InterfaceType.__proto__ || Object.getPrototypeOf(InterfaceType)).call(this, introspectionType));
	
	        _this4.fields = introspectionType.fields.map(function (f) {
	            return new Field(f);
	        });
	        _this4.possibleTypes = introspectionType.possibleTypes.map(function (r) {
	            return TypeRef.fromIntrospectionRef(r);
	        });
	        return _this4;
	    }
	
	    return InterfaceType;
	}(Type);
	
	var EnumType = exports.EnumType = function (_Type4) {
	    _inherits(EnumType, _Type4);
	
	    function EnumType(introspectionType) {
	        _classCallCheck(this, EnumType);
	
	        if (!(introspectionType.kind === 'ENUM')) {
	            throw new Error('Function "EnumType" precondition failed: introspectionType.kind === \'ENUM\'');
	        }
	
	        if (!Array.isArray(introspectionType.enumValues)) {
	            throw new Error('Function "EnumType" precondition failed: Array.isArray(introspectionType.enumValues)');
	        }
	
	        var _this5 = _possibleConstructorReturn(this, (EnumType.__proto__ || Object.getPrototypeOf(EnumType)).call(this, introspectionType));
	
	        _this5.enumValues = introspectionType.enumValues.map(function (v) {
	            return new EnumValue(v);
	        });
	        return _this5;
	    }
	
	    return EnumType;
	}(Type);
	
	var InputObjectType = exports.InputObjectType = function (_Type5) {
	    _inherits(InputObjectType, _Type5);
	
	    function InputObjectType(introspectionType) {
	        _classCallCheck(this, InputObjectType);
	
	        if (!(introspectionType.kind === 'INPUT_OBJECT')) {
	            throw new Error('Function "InputObjectType" precondition failed: introspectionType.kind === \'INPUT_OBJECT\'');
	        }
	
	        if (!Array.isArray(introspectionType.inputFields)) {
	            throw new Error('Function "InputObjectType" precondition failed: Array.isArray(introspectionType.inputFields)');
	        }
	
	        var _this6 = _possibleConstructorReturn(this, (InputObjectType.__proto__ || Object.getPrototypeOf(InputObjectType)).call(this, introspectionType));
	
	        _this6.inputFields = introspectionType.inputFields.map(function (f) {
	            return new InputValue(f);
	        });
	        return _this6;
	    }
	
	    return InputObjectType;
	}(Type);
	
	var Field = exports.Field = function Field(introspectionField) {
	    _classCallCheck(this, Field);
	
	    if (!(typeof introspectionField.name === 'string')) {
	        throw new Error('Function "Field" precondition failed: typeof introspectionField.name === \'string\'');
	    }
	
	    if (!(introspectionField.description === null || typeof introspectionField.description === 'string')) {
	        throw new Error('Function "Field" precondition failed: introspectionField.description === null || typeof introspectionField.description === \'string\'');
	    }
	
	    if (!introspectionField.type) {
	        throw new Error('Function "Field" precondition failed: introspectionField.type');
	    }
	
	    if (!Array.isArray(introspectionField.args)) {
	        throw new Error('Function "Field" precondition failed: Array.isArray(introspectionField.args)');
	    }
	
	    this.name = introspectionField.name;
	    this.description = introspectionField.description;
	    this.args = introspectionField.args.map(function (a) {
	        return new InputValue(a);
	    });
	    this.type = TypeRef.fromIntrospectionRef(introspectionField.type);
	};
	
	var InputValue = exports.InputValue = function InputValue(introspectionValue) {
	    _classCallCheck(this, InputValue);
	
	    if (!(typeof introspectionValue.name === 'string')) {
	        throw new Error('Function "InputValue" precondition failed: typeof introspectionValue.name === \'string\'');
	    }
	
	    if (!(introspectionValue.description === null || typeof introspectionValue.description === 'string')) {
	        throw new Error('Function "InputValue" precondition failed: introspectionValue.description === null || typeof introspectionValue.description === \'string\'');
	    }
	
	    if (!introspectionValue.type) {
	        throw new Error('Function "InputValue" precondition failed: introspectionValue.type');
	    }
	
	    if (!(introspectionValue.defaultValue !== undefined)) {
	        throw new Error('Function "InputValue" precondition failed: introspectionValue.defaultValue !== undefined');
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
	            throw new Error('Function "TypeRef" precondition failed: this.constructor !== TypeRef');
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
	            throw new Error('Function "NonNullTypeRef" precondition failed: introspectionRef.ofType');
	        }
	
	        var _this7 = _possibleConstructorReturn(this, (NonNullTypeRef.__proto__ || Object.getPrototypeOf(NonNullTypeRef)).call(this));
	
	        _this7.ofType = TypeRef.fromIntrospectionRef(introspectionRef.ofType);
	        return _this7;
	    }
	
	    return NonNullTypeRef;
	}(TypeRef);
	
	var NamedTypeRef = exports.NamedTypeRef = function (_TypeRef2) {
	    _inherits(NamedTypeRef, _TypeRef2);
	
	    function NamedTypeRef(introspectionRef) {
	        _classCallCheck(this, NamedTypeRef);
	
	        if (!(typeof introspectionRef.name === 'string')) {
	            throw new Error('Function "NamedTypeRef" precondition failed: typeof introspectionRef.name === \'string\'');
	        }
	
	        var _this8 = _possibleConstructorReturn(this, (NamedTypeRef.__proto__ || Object.getPrototypeOf(NamedTypeRef)).call(this));
	
	        _this8.typeName = introspectionRef.name;
	        return _this8;
	    }
	
	    return NamedTypeRef;
	}(TypeRef);
	
	var ListTypeRef = exports.ListTypeRef = function (_TypeRef3) {
	    _inherits(ListTypeRef, _TypeRef3);
	
	    function ListTypeRef(introspectionRef) {
	        _classCallCheck(this, ListTypeRef);
	
	        if (!introspectionRef.ofType) {
	            throw new Error('Function "ListTypeRef" precondition failed: introspectionRef.ofType');
	        }
	
	        var _this9 = _possibleConstructorReturn(this, (ListTypeRef.__proto__ || Object.getPrototypeOf(ListTypeRef)).call(this));
	
	        _this9.ofType = TypeRef.fromIntrospectionRef(introspectionRef.ofType);
	        return _this9;
	    }
	
	    return ListTypeRef;
	}(TypeRef);
	
	var EnumValue = exports.EnumValue = function EnumValue(introspectionValue) {
	    _classCallCheck(this, EnumValue);
	
	    if (!(typeof introspectionValue.name === 'string')) {
	        throw new Error('Function "EnumValue" precondition failed: typeof introspectionValue.name === \'string\'');
	    }
	
	    if (!(introspectionValue.description === null || typeof introspectionValue.description === 'string')) {
	        throw new Error('Function "EnumValue" precondition failed: introspectionValue.description === null || typeof introspectionValue.description === \'string\'');
	    }
	
	    if (!(typeof introspectionValue.isDeprecated === 'boolean')) {
	        throw new Error('Function "EnumValue" precondition failed: typeof introspectionValue.isDeprecated === \'boolean\'');
	    }
	
	    if (!(!introspectionValue.isDeprecated || typeof introspectionValue.deprecationReason === 'string')) {
	        throw new Error('Function "EnumValue" precondition failed: !introspectionValue.isDeprecated || typeof introspectionValue.deprecationReason === \'string\'');
	    }
	
	    if (!(introspectionValue.isDeprecated || introspectionValue.deprecationReason === null)) {
	        throw new Error('Function "EnumValue" precondition failed: introspectionValue.isDeprecated || introspectionValue.deprecationReason === null');
	    }
	
	    this.name = introspectionValue.name;
	    this.description = introspectionValue.description;
	    this.isDeprecated = introspectionValue.isDeprecated;
	    this.deprecationReason = introspectionValue.deprecationReason;
	};

/***/ },
/* 4 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	    value: true
	});
	exports.getReferencesInSchema = getReferencesInSchema;
	
	var _model = __webpack_require__(3);
	
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

/***/ },
/* 5 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	    value: true
	});
	exports.InputObjectDocsView = exports.ScalarDocsView = exports.EnumDocsView = exports.InterfaceDocsView = exports.ObjectDocsView = undefined;
	
	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();
	
	var _react = __webpack_require__(1);
	
	var _react2 = _interopRequireDefault(_react);
	
	var _model = __webpack_require__(3);
	
	var _DescriptionView = __webpack_require__(6);
	
	var _FieldView = __webpack_require__(12);
	
	var _TypeRefView = __webpack_require__(14);
	
	var _FieldArgumentsTableView = __webpack_require__(20);
	
	var _TypeDocsViews = __webpack_require__(25);
	
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
	
	var InterfaceDocsView = exports.InterfaceDocsView = function (_React$Component2) {
	    _inherits(InterfaceDocsView, _React$Component2);
	
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
	
	var EnumDocsView = exports.EnumDocsView = function (_React$Component3) {
	    _inherits(EnumDocsView, _React$Component3);
	
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
	
	var ScalarDocsView = exports.ScalarDocsView = function (_React$Component4) {
	    _inherits(ScalarDocsView, _React$Component4);
	
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
	
	var InputObjectDocsView = exports.InputObjectDocsView = function (_React$Component5) {
	    _inherits(InputObjectDocsView, _React$Component5);
	
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
	    var titleOverride = arguments.length <= 1 || arguments[1] === undefined ? null : arguments[1];
	
	    return _react2.default.createElement(
	        'h2',
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
	                                className: StyleSheet.enumName
	                            },
	                            v.name
	                        ),
	                        _react2.default.createElement(
	                            'td',
	                            null,
	                            v.description && _react2.default.createElement(_DescriptionView.DescriptionView, { description: v.description })
	                        )
	                    );
	                })
	            )
	        )
	    );
	}

/***/ },
/* 6 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	    value: true
	});
	exports.DescriptionView = undefined;
	
	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();
	
	var _react = __webpack_require__(1);
	
	var _react2 = _interopRequireDefault(_react);
	
	var _marked = __webpack_require__(7);
	
	var _marked2 = _interopRequireDefault(_marked);
	
	var _DescriptionView = __webpack_require__(8);
	
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

/***/ },
/* 7 */
/***/ function(module, exports, __webpack_require__) {

	/* WEBPACK VAR INJECTION */(function(global) {/**
	 * marked - a markdown parser
	 * Copyright (c) 2011-2014, Christopher Jeffrey. (MIT Licensed)
	 * https://github.com/chjj/marked
	 */
	
	;(function() {
	
	/**
	 * Block-Level Grammar
	 */
	
	var block = {
	  newline: /^\n+/,
	  code: /^( {4}[^\n]+\n*)+/,
	  fences: noop,
	  hr: /^( *[-*_]){3,} *(?:\n+|$)/,
	  heading: /^ *(#{1,6}) *([^\n]+?) *#* *(?:\n+|$)/,
	  nptable: noop,
	  lheading: /^([^\n]+)\n *(=|-){2,} *(?:\n+|$)/,
	  blockquote: /^( *>[^\n]+(\n(?!def)[^\n]+)*\n*)+/,
	  list: /^( *)(bull) [\s\S]+?(?:hr|def|\n{2,}(?! )(?!\1bull )\n*|\s*$)/,
	  html: /^ *(?:comment *(?:\n|\s*$)|closed *(?:\n{2,}|\s*$)|closing *(?:\n{2,}|\s*$))/,
	  def: /^ *\[([^\]]+)\]: *<?([^\s>]+)>?(?: +["(]([^\n]+)[")])? *(?:\n+|$)/,
	  table: noop,
	  paragraph: /^((?:[^\n]+\n?(?!hr|heading|lheading|blockquote|tag|def))+)\n*/,
	  text: /^[^\n]+/
	};
	
	block.bullet = /(?:[*+-]|\d+\.)/;
	block.item = /^( *)(bull) [^\n]*(?:\n(?!\1bull )[^\n]*)*/;
	block.item = replace(block.item, 'gm')
	  (/bull/g, block.bullet)
	  ();
	
	block.list = replace(block.list)
	  (/bull/g, block.bullet)
	  ('hr', '\\n+(?=\\1?(?:[-*_] *){3,}(?:\\n+|$))')
	  ('def', '\\n+(?=' + block.def.source + ')')
	  ();
	
	block.blockquote = replace(block.blockquote)
	  ('def', block.def)
	  ();
	
	block._tag = '(?!(?:'
	  + 'a|em|strong|small|s|cite|q|dfn|abbr|data|time|code'
	  + '|var|samp|kbd|sub|sup|i|b|u|mark|ruby|rt|rp|bdi|bdo'
	  + '|span|br|wbr|ins|del|img)\\b)\\w+(?!:/|[^\\w\\s@]*@)\\b';
	
	block.html = replace(block.html)
	  ('comment', /<!--[\s\S]*?-->/)
	  ('closed', /<(tag)[\s\S]+?<\/\1>/)
	  ('closing', /<tag(?:"[^"]*"|'[^']*'|[^'">])*?>/)
	  (/tag/g, block._tag)
	  ();
	
	block.paragraph = replace(block.paragraph)
	  ('hr', block.hr)
	  ('heading', block.heading)
	  ('lheading', block.lheading)
	  ('blockquote', block.blockquote)
	  ('tag', '<' + block._tag)
	  ('def', block.def)
	  ();
	
	/**
	 * Normal Block Grammar
	 */
	
	block.normal = merge({}, block);
	
	/**
	 * GFM Block Grammar
	 */
	
	block.gfm = merge({}, block.normal, {
	  fences: /^ *(`{3,}|~{3,})[ \.]*(\S+)? *\n([\s\S]*?)\s*\1 *(?:\n+|$)/,
	  paragraph: /^/,
	  heading: /^ *(#{1,6}) +([^\n]+?) *#* *(?:\n+|$)/
	});
	
	block.gfm.paragraph = replace(block.paragraph)
	  ('(?!', '(?!'
	    + block.gfm.fences.source.replace('\\1', '\\2') + '|'
	    + block.list.source.replace('\\1', '\\3') + '|')
	  ();
	
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
	
	Lexer.prototype.token = function(src, top, bq) {
	  var src = src.replace(/^ +$/gm, '')
	    , next
	    , loose
	    , cap
	    , bull
	    , b
	    , item
	    , space
	    , i
	    , l;
	
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
	      this.token(cap, top, true);
	
	      this.tokens.push({
	        type: 'blockquote_end'
	      });
	
	      continue;
	    }
	
	    // list
	    if (cap = this.rules.list.exec(src)) {
	      src = src.substring(cap[0].length);
	      bull = cap[2];
	
	      this.tokens.push({
	        type: 'list_start',
	        ordered: bull.length > 1
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
	        this.token(item, false, bq);
	
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
	    if ((!bq && top) && (cap = this.rules.def.exec(src))) {
	      src = src.substring(cap[0].length);
	      this.tokens.links[cap[1].toLowerCase()] = {
	        href: cap[2],
	        title: cap[3]
	      };
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
	      throw new
	        Error('Infinite loop on byte: ' + src.charCodeAt(0));
	    }
	  }
	
	  return this.tokens;
	};
	
	/**
	 * Inline-Level Grammar
	 */
	
	var inline = {
	  escape: /^\\([\\`*{}\[\]()#+\-.!_>])/,
	  autolink: /^<([^ >]+(@|:\/)[^ >]+)>/,
	  url: noop,
	  tag: /^<!--[\s\S]*?-->|^<\/?\w+(?:"[^"]*"|'[^']*'|[^'">])*?>/,
	  link: /^!?\[(inside)\]\(href\)/,
	  reflink: /^!?\[(inside)\]\s*\[([^\]]*)\]/,
	  nolink: /^!?\[((?:\[[^\]]*\]|[^\[\]])*)\]/,
	  strong: /^__([\s\S]+?)__(?!_)|^\*\*([\s\S]+?)\*\*(?!\*)/,
	  em: /^\b_((?:[^_]|__)+?)_\b|^\*((?:\*\*|[\s\S])+?)\*(?!\*)/,
	  code: /^(`+)\s*([\s\S]*?[^`])\s*\1(?!`)/,
	  br: /^ {2,}\n(?!\s*$)/,
	  del: noop,
	  text: /^[\s\S]+?(?=[\\<!\[_*`]| {2,}\n|$)/
	};
	
	inline._inside = /(?:\[[^\]]*\]|[^\[\]]|\](?=[^\[]*\]))*/;
	inline._href = /\s*<?([\s\S]*?)>?(?:\s+['"]([\s\S]*?)['"])?\s*/;
	
	inline.link = replace(inline.link)
	  ('inside', inline._inside)
	  ('href', inline._href)
	  ();
	
	inline.reflink = replace(inline.reflink)
	  ('inside', inline._inside)
	  ();
	
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
	  escape: replace(inline.escape)('])', '~|])')(),
	  url: /^(https?:\/\/[^\s<]+[^<.,:;"')\]\s])/,
	  del: /^~~(?=\S)([\s\S]*?\S)~~/,
	  text: replace(inline.text)
	    (']|', '~]|')
	    ('|', '|https?://|')
	    ()
	});
	
	/**
	 * GFM + Line Breaks Inline Grammar
	 */
	
	inline.breaks = merge({}, inline.gfm, {
	  br: replace(inline.br)('{2,}', '*')(),
	  text: replace(inline.gfm.text)('{2,}', '*')()
	});
	
	/**
	 * Inline Lexer & Compiler
	 */
	
	function InlineLexer(links, options) {
	  this.options = options || marked.defaults;
	  this.links = links;
	  this.rules = inline.normal;
	  this.renderer = this.options.renderer || new Renderer;
	  this.renderer.options = this.options;
	
	  if (!this.links) {
	    throw new
	      Error('Tokens array requires a `links` property.');
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
	  var out = ''
	    , link
	    , text
	    , href
	    , cap;
	
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
	        text = cap[1].charAt(6) === ':'
	          ? this.mangle(cap[1].substring(7))
	          : this.mangle(cap[1]);
	        href = this.mangle('mailto:') + text;
	      } else {
	        text = escape(cap[1]);
	        href = text;
	      }
	      out += this.renderer.link(href, null, text);
	      continue;
	    }
	
	    // url (gfm)
	    if (!this.inLink && (cap = this.rules.url.exec(src))) {
	      src = src.substring(cap[0].length);
	      text = escape(cap[1]);
	      href = text;
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
	      out += this.renderer.codespan(escape(cap[2], true));
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
	      throw new
	        Error('Infinite loop on byte: ' + src.charCodeAt(0));
	    }
	  }
	
	  return out;
	};
	
	/**
	 * Compile Link
	 */
	
	InlineLexer.prototype.outputLink = function(cap, link) {
	  var href = escape(link.href)
	    , title = link.title ? escape(link.title) : null;
	
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
	  var out = ''
	    , l = text.length
	    , i = 0
	    , ch;
	
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
	
	Renderer.prototype.list = function(body, ordered) {
	  var type = ordered ? 'ol' : 'ul';
	  return '<' + type + '>\n' + body + '</' + type + '>\n';
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
	      return '';
	    }
	    if (prot.indexOf('javascript:') === 0 || prot.indexOf('vbscript:') === 0) {
	      return '';
	    }
	  }
	  var out = '<a href="' + href + '"';
	  if (title) {
	    out += ' title="' + title + '"';
	  }
	  out += '>' + text + '</a>';
	  return out;
	};
	
	Renderer.prototype.image = function(href, title, text) {
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
	 * Parsing & Compiling
	 */
	
	function Parser(options) {
	  this.tokens = [];
	  this.token = null;
	  this.options = options || marked.defaults;
	  this.options.renderer = this.options.renderer || new Renderer;
	  this.renderer = this.options.renderer;
	  this.renderer.options = this.options;
	}
	
	/**
	 * Static Parse Method
	 */
	
	Parser.parse = function(src, options, renderer) {
	  var parser = new Parser(options, renderer);
	  return parser.parse(src);
	};
	
	/**
	 * Parse Loop
	 */
	
	Parser.prototype.parse = function(src) {
	  this.inline = new InlineLexer(src.links, this.options, this.renderer);
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
	        this.token.text);
	    }
	    case 'code': {
	      return this.renderer.code(this.token.text,
	        this.token.lang,
	        this.token.escaped);
	    }
	    case 'table': {
	      var header = ''
	        , body = ''
	        , i
	        , row
	        , cell
	        , flags
	        , j;
	
	      // header
	      cell = '';
	      for (i = 0; i < this.token.header.length; i++) {
	        flags = { header: true, align: this.token.align[i] };
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
	      var body = '';
	
	      while (this.next().type !== 'blockquote_end') {
	        body += this.tok();
	      }
	
	      return this.renderer.blockquote(body);
	    }
	    case 'list_start': {
	      var body = ''
	        , ordered = this.token.ordered;
	
	      while (this.next().type !== 'list_end') {
	        body += this.tok();
	      }
	
	      return this.renderer.list(body, ordered);
	    }
	    case 'list_item_start': {
	      var body = '';
	
	      while (this.next().type !== 'list_item_end') {
	        body += this.token.type === 'text'
	          ? this.parseText()
	          : this.tok();
	      }
	
	      return this.renderer.listitem(body);
	    }
	    case 'loose_item_start': {
	      var body = '';
	
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
	  return html.replace(/&(#(?:\d+)|(?:#x[0-9A-Fa-f]+)|(?:\w+));?/g, function(_, n) {
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
	
	function replace(regex, opt) {
	  regex = regex.source;
	  opt = opt || '';
	  return function self(name, val) {
	    if (!name) return new RegExp(regex, opt);
	    val = val.source || val;
	    val = val.replace(/(^|[^\[])\^/g, '$1');
	    regex = regex.replace(name, val);
	    return self;
	  };
	}
	
	function noop() {}
	noop.exec = noop;
	
	function merge(obj) {
	  var i = 1
	    , target
	    , key;
	
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
	  if (callback || typeof opt === 'function') {
	    if (!callback) {
	      callback = opt;
	      opt = null;
	    }
	
	    opt = merge({}, marked.defaults, opt || {});
	
	    var highlight = opt.highlight
	      , tokens
	      , pending
	      , i = 0;
	
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
	    e.message += '\nPlease report this to https://github.com/chjj/marked.';
	    if ((opt || marked.defaults).silent) {
	      return '<p>An error occured:</p><pre>'
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
	  renderer: new Renderer,
	  xhtml: false
	};
	
	/**
	 * Expose
	 */
	
	marked.Parser = Parser;
	marked.parser = Parser.parse;
	
	marked.Renderer = Renderer;
	
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
	  this.marked = marked;
	}
	
	}).call(function() {
	  return this || (typeof window !== 'undefined' ? window : global);
	}());
	
	/* WEBPACK VAR INJECTION */}.call(exports, (function() { return this; }())))

/***/ },
/* 8 */
/***/ function(module, exports, __webpack_require__) {

	// style-loader: Adds some css to the DOM by adding a <style> tag
	
	// load the styles
	var content = __webpack_require__(9);
	if(typeof content === 'string') content = [[module.id, content, '']];
	// add the styles to the DOM
	var update = __webpack_require__(11)(content, {});
	if(content.locals) module.exports = content.locals;
	// Hot Module Replacement
	if(false) {
		// When the styles change, update the <style> tags
		if(!content.locals) {
			module.hot.accept("!!./../../node_modules/css-loader/index.js?modules&importLoaders=1!./../../node_modules/postcss-loader/index.js!./DescriptionView.css", function() {
				var newContent = require("!!./../../node_modules/css-loader/index.js?modules&importLoaders=1!./../../node_modules/postcss-loader/index.js!./DescriptionView.css");
				if(typeof newContent === 'string') newContent = [[module.id, newContent, '']];
				update(newContent);
			});
		}
		// When the module is disposed, remove the <style> tags
		module.hot.dispose(function() { update(); });
	}

/***/ },
/* 9 */
/***/ function(module, exports, __webpack_require__) {

	exports = module.exports = __webpack_require__(10)();
	// imports
	
	
	// module
	exports.push([module.id, "._1S63EXzJ2LWrq2TSLX8cAu :first-child {\n    margin-top: 0;\n}\n\n._1S63EXzJ2LWrq2TSLX8cAu :last-child {\n    margin-bottom: 0;\n}\n\n._1S63EXzJ2LWrq2TSLX8cAu h1 {\n    font-size: 1.3em;\n}\n\n._1S63EXzJ2LWrq2TSLX8cAu h2 {\n    font-size: 1.1em;\n}\n\n._1S63EXzJ2LWrq2TSLX8cAu h3 {\n    font-size: 1em;\n    -webkit-font-feature-settings: \"c2sc\";\n            font-feature-settings: \"c2sc\";\n    font-variant: small-caps;\n}\n\n._1S63EXzJ2LWrq2TSLX8cAu blockquote {\n    border-left: 8px solid #e8e8e8;\n    margin-top: -0.3em;\n    padding-top: 0.3em;\n    margin-left: 20px;\n    padding-left: 12px;\n    margin-bottom: -0.5em;\n    padding-bottom: 0.5em;\n}\n", ""]);
	
	// exports
	exports.locals = {
		"container": "_1S63EXzJ2LWrq2TSLX8cAu"
	};

/***/ },
/* 10 */
/***/ function(module, exports) {

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


/***/ },
/* 11 */
/***/ function(module, exports, __webpack_require__) {

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
			return /msie [6-9]\b/.test(window.navigator.userAgent.toLowerCase());
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


/***/ },
/* 12 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	    value: true
	});
	exports.FieldView = undefined;
	
	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();
	
	var _react = __webpack_require__(1);
	
	var _react2 = _interopRequireDefault(_react);
	
	var _model = __webpack_require__(3);
	
	var _DescriptionView = __webpack_require__(6);
	
	var _FieldSyntaxView = __webpack_require__(13);
	
	var _FieldArgumentsTableView = __webpack_require__(20);
	
	var _FieldView = __webpack_require__(23);
	
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
	    }]);
	
	    return FieldView;
	}(_react2.default.Component);

/***/ },
/* 13 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	    value: true
	});
	exports.FieldSyntaxView = undefined;
	
	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();
	
	var _react = __webpack_require__(1);
	
	var _react2 = _interopRequireDefault(_react);
	
	var _model = __webpack_require__(3);
	
	var _TypeRefView = __webpack_require__(14);
	
	var _FieldSyntaxView = __webpack_require__(18);
	
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

/***/ },
/* 14 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	    value: true
	});
	exports.TypeRefView = undefined;
	
	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();
	
	var _react = __webpack_require__(1);
	
	var _react2 = _interopRequireDefault(_react);
	
	var _model = __webpack_require__(3);
	
	var _TypeRefView = __webpack_require__(15);
	
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

/***/ },
/* 15 */
/***/ function(module, exports, __webpack_require__) {

	// style-loader: Adds some css to the DOM by adding a <style> tag
	
	// load the styles
	var content = __webpack_require__(16);
	if(typeof content === 'string') content = [[module.id, content, '']];
	// add the styles to the DOM
	var update = __webpack_require__(11)(content, {});
	if(content.locals) module.exports = content.locals;
	// Hot Module Replacement
	if(false) {
		// When the styles change, update the <style> tags
		if(!content.locals) {
			module.hot.accept("!!./../../node_modules/css-loader/index.js?modules&importLoaders=1!./../../node_modules/postcss-loader/index.js!./TypeRefView.css", function() {
				var newContent = require("!!./../../node_modules/css-loader/index.js?modules&importLoaders=1!./../../node_modules/postcss-loader/index.js!./TypeRefView.css");
				if(typeof newContent === 'string') newContent = [[module.id, newContent, '']];
				update(newContent);
			});
		}
		// When the module is disposed, remove the <style> tags
		module.hot.dispose(function() { update(); });
	}

/***/ },
/* 16 */
/***/ function(module, exports, __webpack_require__) {

	exports = module.exports = __webpack_require__(10)();
	// imports
	exports.i(__webpack_require__(17), undefined);
	
	// module
	exports.push([module.id, "._3Ue4q58Ya6q2FCTVkZKllk {\n}\n", ""]);
	
	// exports
	exports.locals = {
		"typeRef": "_3Ue4q58Ya6q2FCTVkZKllk " + __webpack_require__(17).locals["typeLink"] + ""
	};

/***/ },
/* 17 */
/***/ function(module, exports, __webpack_require__) {

	exports = module.exports = __webpack_require__(10)();
	// imports
	
	
	// module
	exports.push([module.id, "._3_QndMLrl0DS7txXsKk5aM {\n    color: #5b2699;\n}\n\n._1QSb_Lywz03jNMCELm-GrU {\n    padding-right: 16px;\n    padding-right: 1rem;\n    white-space: nowrap;\n}\n\n._3a5669pwdwJabgmbtJHumc {\n    line-height: 1.3;\n}\n\n._3Xlbyq0Qo-JOAJLLx2z9-l {\n    color: #64381f;\n}\n\n.NgU4gHjdynLJU2YSbF4ic {\n    color: #836c28;\n}\n\n._15sahXcXCjIULC63jwKqZE {\n    color: #007400;\n}\n\n._1ssUqN390ygEtVlxHSnU0e,\n._1ssUqN390ygEtVlxHSnU0e:active,\n._1ssUqN390ygEtVlxHSnU0e:hover,\n._1ssUqN390ygEtVlxHSnU0e:visited {\n    color: #007400;\n}\n", ""]);
	
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

/***/ },
/* 18 */
/***/ function(module, exports, __webpack_require__) {

	// style-loader: Adds some css to the DOM by adding a <style> tag
	
	// load the styles
	var content = __webpack_require__(19);
	if(typeof content === 'string') content = [[module.id, content, '']];
	// add the styles to the DOM
	var update = __webpack_require__(11)(content, {});
	if(content.locals) module.exports = content.locals;
	// Hot Module Replacement
	if(false) {
		// When the styles change, update the <style> tags
		if(!content.locals) {
			module.hot.accept("!!./../../node_modules/css-loader/index.js?modules&importLoaders=1!./../../node_modules/postcss-loader/index.js!./FieldSyntaxView.css", function() {
				var newContent = require("!!./../../node_modules/css-loader/index.js?modules&importLoaders=1!./../../node_modules/postcss-loader/index.js!./FieldSyntaxView.css");
				if(typeof newContent === 'string') newContent = [[module.id, newContent, '']];
				update(newContent);
			});
		}
		// When the module is disposed, remove the <style> tags
		module.hot.dispose(function() { update(); });
	}

/***/ },
/* 19 */
/***/ function(module, exports, __webpack_require__) {

	exports = module.exports = __webpack_require__(10)();
	// imports
	exports.i(__webpack_require__(17), undefined);
	
	// module
	exports.push([module.id, "._3Q9rTqv61jz1TMbQgSC21Y {\n    margin-bottom: 3.2px;\n    margin-bottom: 0.2rem;\n}\n\n.pfwgw1KVkaL-Jspb7XsLn {\n}\n\n._3qTEJI-SGaaBwcproq96Z9 {\n}\n\n._1C3jrn92-2_teD3Q_-WwDn {\n}\n", ""]);
	
	// exports
	exports.locals = {
		"container": "_3Q9rTqv61jz1TMbQgSC21Y",
		"name": "pfwgw1KVkaL-Jspb7XsLn " + __webpack_require__(17).locals["fieldName"] + "",
		"argumentName": "_3qTEJI-SGaaBwcproq96Z9 " + __webpack_require__(17).locals["argumentName"] + "",
		"defaultValue": "_1C3jrn92-2_teD3Q_-WwDn " + __webpack_require__(17).locals["defaultValue"] + ""
	};

/***/ },
/* 20 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	Object.defineProperty(exports, "__esModule", {
	    value: true
	});
	exports.FieldArgumentsTableView = undefined;
	
	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();
	
	var _react = __webpack_require__(1);
	
	var _react2 = _interopRequireDefault(_react);
	
	var _model = __webpack_require__(3);
	
	var _TypeRefView = __webpack_require__(14);
	
	var _DescriptionView = __webpack_require__(6);
	
	var _FieldArgumentsTableView = __webpack_require__(21);
	
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
	                { className: StyleSheet.table },
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

/***/ },
/* 21 */
/***/ function(module, exports, __webpack_require__) {

	// style-loader: Adds some css to the DOM by adding a <style> tag
	
	// load the styles
	var content = __webpack_require__(22);
	if(typeof content === 'string') content = [[module.id, content, '']];
	// add the styles to the DOM
	var update = __webpack_require__(11)(content, {});
	if(content.locals) module.exports = content.locals;
	// Hot Module Replacement
	if(false) {
		// When the styles change, update the <style> tags
		if(!content.locals) {
			module.hot.accept("!!./../../node_modules/css-loader/index.js?modules&importLoaders=1!./../../node_modules/postcss-loader/index.js!./FieldArgumentsTableView.css", function() {
				var newContent = require("!!./../../node_modules/css-loader/index.js?modules&importLoaders=1!./../../node_modules/postcss-loader/index.js!./FieldArgumentsTableView.css");
				if(typeof newContent === 'string') newContent = [[module.id, newContent, '']];
				update(newContent);
			});
		}
		// When the module is disposed, remove the <style> tags
		module.hot.dispose(function() { update(); });
	}

/***/ },
/* 22 */
/***/ function(module, exports, __webpack_require__) {

	exports = module.exports = __webpack_require__(10)();
	// imports
	exports.i(__webpack_require__(17), undefined);
	
	// module
	exports.push([module.id, "._2u0NKWFUVO10_7zl5FH1bX {\n    margin-top: 16px;\n    margin-top: 1rem;\n    margin-left: 32px;\n    margin-left: 2rem;\n    width: calc(100% - 2rem);\n}\n\n._14Noc9w-o_IUonJxsVOnBQ {\n    text-align: left;\n    font-size: 17.6px;\n    font-size: 1.1rem;\n    border-bottom: 1px solid #d9d9d9;\n}\n\n._3qzzdu41HzTOjXefzRE8dy {\n}\n\n._3g8_wlJYIQqfvRx4Tdzt4u {\n    width: 100%;\n}\n\n._1XONXofpDzZZq1kxZDtU2p {\n}\n\n.Sb22PNqbe2ZV1oFtChBAD {\n}\n", ""]);
	
	// exports
	exports.locals = {
		"table": "_2u0NKWFUVO10_7zl5FH1bX",
		"header": "_14Noc9w-o_IUonJxsVOnBQ",
		"key": "_3qzzdu41HzTOjXefzRE8dy " + __webpack_require__(17).locals["argumentCell"] + "",
		"value": "_3g8_wlJYIQqfvRx4Tdzt4u",
		"row": "_1XONXofpDzZZq1kxZDtU2p " + __webpack_require__(17).locals["argumentRow"] + "",
		"argumentName": "Sb22PNqbe2ZV1oFtChBAD " + __webpack_require__(17).locals["argumentName"] + ""
	};

/***/ },
/* 23 */
/***/ function(module, exports, __webpack_require__) {

	// style-loader: Adds some css to the DOM by adding a <style> tag
	
	// load the styles
	var content = __webpack_require__(24);
	if(typeof content === 'string') content = [[module.id, content, '']];
	// add the styles to the DOM
	var update = __webpack_require__(11)(content, {});
	if(content.locals) module.exports = content.locals;
	// Hot Module Replacement
	if(false) {
		// When the styles change, update the <style> tags
		if(!content.locals) {
			module.hot.accept("!!./../../node_modules/css-loader/index.js?modules&importLoaders=1!./../../node_modules/postcss-loader/index.js!./FieldView.css", function() {
				var newContent = require("!!./../../node_modules/css-loader/index.js?modules&importLoaders=1!./../../node_modules/postcss-loader/index.js!./FieldView.css");
				if(typeof newContent === 'string') newContent = [[module.id, newContent, '']];
				update(newContent);
			});
		}
		// When the module is disposed, remove the <style> tags
		module.hot.dispose(function() { update(); });
	}

/***/ },
/* 24 */
/***/ function(module, exports, __webpack_require__) {

	exports = module.exports = __webpack_require__(10)();
	// imports
	
	
	// module
	exports.push([module.id, "._2CI__araY4C94OAnkGP8Fv {\n    margin-bottom: 24px;\n    margin-bottom: 1.5rem;\n}\n\n._158AUimPZVUE217-1MuDQx {\n    margin-left: 32px;\n    margin-left: 2rem;\n}\n\n._158AUimPZVUE217-1MuDQx p {\n    margin-top: 0;\n}\n", ""]);
	
	// exports
	exports.locals = {
		"container": "_2CI__araY4C94OAnkGP8Fv",
		"description": "_158AUimPZVUE217-1MuDQx"
	};

/***/ },
/* 25 */
/***/ function(module, exports, __webpack_require__) {

	// style-loader: Adds some css to the DOM by adding a <style> tag
	
	// load the styles
	var content = __webpack_require__(26);
	if(typeof content === 'string') content = [[module.id, content, '']];
	// add the styles to the DOM
	var update = __webpack_require__(11)(content, {});
	if(content.locals) module.exports = content.locals;
	// Hot Module Replacement
	if(false) {
		// When the styles change, update the <style> tags
		if(!content.locals) {
			module.hot.accept("!!./../../node_modules/css-loader/index.js?modules&importLoaders=1!./../../node_modules/postcss-loader/index.js!./TypeDocsViews.css", function() {
				var newContent = require("!!./../../node_modules/css-loader/index.js?modules&importLoaders=1!./../../node_modules/postcss-loader/index.js!./TypeDocsViews.css");
				if(typeof newContent === 'string') newContent = [[module.id, newContent, '']];
				update(newContent);
			});
		}
		// When the module is disposed, remove the <style> tags
		module.hot.dispose(function() { update(); });
	}

/***/ },
/* 26 */
/***/ function(module, exports, __webpack_require__) {

	exports = module.exports = __webpack_require__(10)();
	// imports
	exports.i(__webpack_require__(17), undefined);
	
	// module
	exports.push([module.id, "._31nGuA4VcO5ASJ1Y-50NC0 {\n    margin-bottom: 20px;\n}\n\n._1hBwBkrQ8ZlOyOUcLvjRpt {\n    margin-bottom: 8px;\n    margin-bottom: 0.5rem;\n}\n\n._1gsHTtZCfZy0kwT90S9nZC {\n    -webkit-font-feature-settings: \"c2sc\";\n            font-feature-settings: \"c2sc\";\n    font-variant: small-caps;\n    text-transform: uppercase;\n    font-weight: bold;\n    color: #4a4a4a;\n    border-bottom: 1px solid #d9d9d9;\n    margin-top: 16px;\n    margin-top: 1rem;\n    margin-bottom: 8px;\n    margin-bottom: 0.5rem;\n}\n\n._2rkCQUiZ63eNMyTCRDL7GX {\n    list-style: none;\n    margin: 0;\n    padding: 0;\n}\n\n.hI41jTQ51eUSGSCTegJoD {\n}\n\n.bHFx-gWNy1lALB9MKGx6U {\n}\n", ""]);
	
	// exports
	exports.locals = {
		"type": "_31nGuA4VcO5ASJ1Y-50NC0",
		"heading": "_1hBwBkrQ8ZlOyOUcLvjRpt",
		"subHeading": "_1gsHTtZCfZy0kwT90S9nZC",
		"interfacesList": "_2rkCQUiZ63eNMyTCRDL7GX",
		"enumName": "hI41jTQ51eUSGSCTegJoD " + __webpack_require__(17).locals["argumentName"] + " " + __webpack_require__(17).locals["argumentCell"] + "",
		"enumRow": "bHFx-gWNy1lALB9MKGx6U " + __webpack_require__(17).locals["argumentRow"] + ""
	};

/***/ },
/* 27 */
/***/ function(module, exports, __webpack_require__) {

	// style-loader: Adds some css to the DOM by adding a <style> tag
	
	// load the styles
	var content = __webpack_require__(28);
	if(typeof content === 'string') content = [[module.id, content, '']];
	// add the styles to the DOM
	var update = __webpack_require__(11)(content, {});
	if(content.locals) module.exports = content.locals;
	// Hot Module Replacement
	if(false) {
		// When the styles change, update the <style> tags
		if(!content.locals) {
			module.hot.accept("!!./../../node_modules/css-loader/index.js?modules&importLoaders=1!./../../node_modules/postcss-loader/index.js!./SchemaDocsView.css", function() {
				var newContent = require("!!./../../node_modules/css-loader/index.js?modules&importLoaders=1!./../../node_modules/postcss-loader/index.js!./SchemaDocsView.css");
				if(typeof newContent === 'string') newContent = [[module.id, newContent, '']];
				update(newContent);
			});
		}
		// When the module is disposed, remove the <style> tags
		module.hot.dispose(function() { update(); });
	}

/***/ },
/* 28 */
/***/ function(module, exports, __webpack_require__) {

	exports = module.exports = __webpack_require__(10)();
	// imports
	exports.i(__webpack_require__(29), "");
	
	// module
	exports.push([module.id, "._2Wa9wu-awiDVZ9IXTPcyFt {\n    display: -webkit-box;\n    display: -ms-flexbox;\n    display: flex;\n    -webkit-box-pack: center;\n        -ms-flex-pack: center;\n            justify-content: center;\n}\n\n._38MtHDcUga2pYTxIRJJZ8o {\n    max-width: 800px;\n}\n", ""]);
	
	// exports
	exports.locals = {
		"wrapper": "_2Wa9wu-awiDVZ9IXTPcyFt",
		"container": "_38MtHDcUga2pYTxIRJJZ8o"
	};

/***/ },
/* 29 */
/***/ function(module, exports, __webpack_require__) {

	exports = module.exports = __webpack_require__(10)();
	// imports
	
	
	// module
	exports.push([module.id, "/*! normalize.css v4.1.1 | MIT License | github.com/necolas/normalize.css */\n\n* {\n  box-sizing: border-box;\n}\n\n/**\n * 1. Change the default font family in all browsers (opinionated).\n * 2. Prevent adjustments of font size after orientation changes in IE and iOS.\n */\n\nhtml {\n  font-family: -apple-system, BlinkMacSystemFont,\n    \"Segoe UI\", \"Roboto\", \"Oxygen\", \"Ubuntu\", \"Cantarell\",\n    \"Fira Sans\", \"Droid Sans\", \"Helvetica Neue\",\n    sans-serif; /* 1 */\n  -ms-text-size-adjust: 100%; /* 2 */\n  -webkit-text-size-adjust: 100%; /* 2 */\n}\n\n/**\n * Remove the margin in all browsers (opinionated).\n */\n\nbody {\n  margin: 0 8px;\n}\n\n/* HTML5 display definitions\n   ========================================================================== */\n\n/**\n * Add the correct display in IE 9-.\n * 1. Add the correct display in Edge, IE, and Firefox.\n * 2. Add the correct display in IE.\n */\n\narticle,\naside,\ndetails, /* 1 */\nfigcaption,\nfigure,\nfooter,\nheader,\nmain, /* 2 */\nmenu,\nnav,\nsection,\nsummary { /* 1 */\n  display: block;\n}\n\n/**\n * Add the correct display in IE 9-.\n */\n\naudio,\ncanvas,\nprogress,\nvideo {\n  display: inline-block;\n}\n\n/**\n * Add the correct display in iOS 4-7.\n */\n\naudio:not([controls]) {\n  display: none;\n  height: 0;\n}\n\n/**\n * Add the correct vertical alignment in Chrome, Firefox, and Opera.\n */\n\nprogress {\n  vertical-align: baseline;\n}\n\n/**\n * Add the correct display in IE 10-.\n * 1. Add the correct display in IE.\n */\n\ntemplate, /* 1 */\n[hidden] {\n  display: none;\n}\n\n/* Links\n   ========================================================================== */\n\n/**\n * 1. Remove the gray background on active links in IE 10.\n * 2. Remove gaps in links underline in iOS 8+ and Safari 8+.\n */\n\na {\n  background-color: transparent; /* 1 */\n   -webkit-text-decoration-skip: ink;  /* 2 */\n}\n\n/**\n * Remove the outline on focused links when they are also active or hovered\n * in all browsers (opinionated).\n */\n\na:active,\na:hover {\n  outline-width: 0;\n}\n\n/* Text-level semantics\n   ========================================================================== */\n\n/**\n * 1. Remove the bottom border in Firefox 39-.\n * 2. Add the correct text decoration in Chrome, Edge, IE, Opera, and Safari.\n */\n\nabbr[title] {\n  border-bottom: none; /* 1 */\n  text-decoration: underline; /* 2 */\n  text-decoration: underline dotted; /* 2 */\n}\n\n/**\n * Prevent the duplicate application of `bolder` by the next rule in Safari 6.\n */\n\nb,\nstrong {\n  font-weight: inherit;\n}\n\n/**\n * Add the correct font weight in Chrome, Edge, and Safari.\n */\n\nb,\nstrong {\n  font-weight: bolder;\n}\n\n/**\n * Add the correct font style in Android 4.3-.\n */\n\ndfn {\n  font-style: italic;\n}\n\n/**\n * Correct the font size and margin on `h1` elements within `section` and\n * `article` contexts in Chrome, Firefox, and Safari.\n */\n\nh1 {\n  font-size: 2em;\n  margin: 0.67em 0;\n}\n\n/**\n * Add the correct background and color in IE 9-.\n */\n\nmark {\n  background-color: #ff0;\n  color: #000;\n}\n\n/**\n * Add the correct font size in all browsers.\n */\n\nsmall {\n  font-size: 80%;\n}\n\n/**\n * Prevent `sub` and `sup` elements from affecting the line height in\n * all browsers.\n */\n\nsub,\nsup {\n  font-size: 75%;\n  line-height: 0;\n  position: relative;\n  vertical-align: baseline;\n}\n\nsub {\n  bottom: -0.25em;\n}\n\nsup {\n  top: -0.5em;\n}\n\n/* Embedded content\n   ========================================================================== */\n\n/**\n * Remove the border on images inside links in IE 10-.\n */\n\nimg {\n  border-style: none;\n}\n\n/**\n * Hide the overflow in IE.\n */\n\nsvg:not(:root) {\n  overflow: hidden;\n}\n\n/* Grouping content\n   ========================================================================== */\n\n/**\n * 1. Correct the inheritance and scaling of font size in all browsers.\n * 2. Correct the odd `em` font sizing in all browsers.\n */\n\ncode,\nkbd,\npre,\nsamp {\n  font-family: monospace, monospace; /* 1 */\n  font-size: 1em; /* 2 */\n}\n\n/**\n * Add the correct margin in IE 8.\n */\n\nfigure {\n  margin: 1em 40px;\n}\n\n/**\n * 1. Add the correct box sizing in Firefox.\n * 2. Show the overflow in Edge and IE.\n */\n\nhr {\n  box-sizing: content-box; /* 1 */\n  height: 0; /* 1 */\n  overflow: visible; /* 2 */\n}\n\n/* Forms\n   ========================================================================== */\n\n/**\n * 1. Change font properties to `inherit` in all browsers (opinionated).\n * 2. Remove the margin in Firefox and Safari.\n */\n\nbutton,\ninput,\noptgroup,\nselect,\ntextarea {\n  font: inherit; /* 1 */\n  margin: 0; /* 2 */\n}\n\n/**\n * Restore the font weight unset by the previous rule.\n */\n\noptgroup {\n  font-weight: bold;\n}\n\n/**\n * Show the overflow in IE.\n * 1. Show the overflow in Edge.\n */\n\nbutton,\ninput { /* 1 */\n  overflow: visible;\n}\n\n/**\n * Remove the inheritance of text transform in Edge, Firefox, and IE.\n * 1. Remove the inheritance of text transform in Firefox.\n */\n\nbutton,\nselect { /* 1 */\n  text-transform: none;\n}\n\n/**\n * 1. Prevent a WebKit bug where (2) destroys native `audio` and `video`\n *    controls in Android 4.\n * 2. Correct the inability to style clickable types in iOS and Safari.\n */\n\nbutton,\nhtml [type=\"button\"], /* 1 */\n[type=\"reset\"],\n[type=\"submit\"] {\n  -webkit-appearance: button; /* 2 */\n}\n\n/**\n * Remove the inner border and padding in Firefox.\n */\n\nbutton::-moz-focus-inner,\n[type=\"button\"]::-moz-focus-inner,\n[type=\"reset\"]::-moz-focus-inner,\n[type=\"submit\"]::-moz-focus-inner {\n  border-style: none;\n  padding: 0;\n}\n\n/**\n * Restore the focus styles unset by the previous rule.\n */\n\nbutton:-moz-focusring,\n[type=\"button\"]:-moz-focusring,\n[type=\"reset\"]:-moz-focusring,\n[type=\"submit\"]:-moz-focusring {\n  outline: 1px dotted ButtonText;\n}\n\n/**\n * Change the border, margin, and padding in all browsers (opinionated).\n */\n\nfieldset {\n  border: 1px solid #c0c0c0;\n  margin: 0 2px;\n  padding: 0.35em 0.625em 0.75em;\n}\n\n/**\n * 1. Correct the text wrapping in Edge and IE.\n * 2. Correct the color inheritance from `fieldset` elements in IE.\n * 3. Remove the padding so developers are not caught out when they zero out\n *    `fieldset` elements in all browsers.\n */\n\nlegend {\n  box-sizing: border-box; /* 1 */\n  color: inherit; /* 2 */\n  display: table; /* 1 */\n  max-width: 100%; /* 1 */\n  padding: 0; /* 3 */\n  white-space: normal; /* 1 */\n}\n\n/**\n * Remove the default vertical scrollbar in IE.\n */\n\ntextarea {\n  overflow: auto;\n}\n\n/**\n * 1. Add the correct box sizing in IE 10-.\n * 2. Remove the padding in IE 10-.\n */\n\n[type=\"checkbox\"],\n[type=\"radio\"] {\n  box-sizing: border-box; /* 1 */\n  padding: 0; /* 2 */\n}\n\n/**\n * Correct the cursor style of increment and decrement buttons in Chrome.\n */\n\n[type=\"number\"]::-webkit-inner-spin-button,\n[type=\"number\"]::-webkit-outer-spin-button {\n  height: auto;\n}\n\n/**\n * 1. Correct the odd appearance in Chrome and Safari.\n * 2. Correct the outline style in Safari.\n */\n\n[type=\"search\"] {\n  -webkit-appearance: textfield; /* 1 */\n  outline-offset: -2px; /* 2 */\n}\n\n/**\n * Remove the inner padding and cancel buttons in Chrome and Safari on OS X.\n */\n\n[type=\"search\"]::-webkit-search-cancel-button,\n[type=\"search\"]::-webkit-search-decoration {\n  -webkit-appearance: none;\n}\n\n/**\n * Correct the text style of placeholders in Chrome, Edge, and Safari.\n */\n\n::-webkit-input-placeholder {\n  color: inherit;\n  opacity: 0.54;\n}\n\n/**\n * 1. Correct the inability to style clickable types in iOS and Safari.\n * 2. Change font properties to `inherit` in Safari.\n */\n\n::-webkit-file-upload-button {\n  -webkit-appearance: button; /* 1 */\n  font: inherit; /* 2 */\n}\n", ""]);
	
	// exports


/***/ },
/* 30 */
/***/ function(module, exports) {

	module.exports = "query IntrospectionQuery {\n  __schema {\n    queryType {\n      name\n    }\n    mutationType {\n      name\n    }\n    subscriptionType {\n      name\n    }\n    types {\n      ...FullType\n    }\n    directives {\n      name\n      description\n      args {\n        ...InputValue\n      }\n      onOperation\n      onFragment\n      onField\n    }\n  }\n}\n\nfragment FullType on __Type {\n  kind\n  name\n  description\n  fields(includeDeprecated: true) {\n    name\n    description\n    args {\n      ...InputValue\n    }\n    type {\n      ...TypeRef\n    }\n    isDeprecated\n    deprecationReason\n  }\n  inputFields {\n    ...InputValue\n  }\n  interfaces {\n    ...TypeRef\n  }\n  enumValues(includeDeprecated: true) {\n    name\n    description\n    isDeprecated\n    deprecationReason\n  }\n  possibleTypes {\n    ...TypeRef\n  }\n}\n\nfragment InputValue on __InputValue {\n  name\n  description\n  type {\n    ...TypeRef\n  }\n  defaultValue\n}\n\nfragment TypeRef on __Type {\n  kind\n  name\n  ofType {\n    kind\n    name\n    ofType {\n      kind\n      name\n      ofType {\n        kind\n        name\n      }\n    }\n  }\n}\n\n"

/***/ }
/******/ ])
});
;
//# sourceMappingURL=graphql-docs.js.map