/*
 * Patroon - Javascript Template Engine
 *
 * Copyright (c) 2008 Matthias Georgi (matthias-georgi.de)
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

function Template(id) {
    this.element = document.getElementById(id);

    if (this.element) {
        this.element.parentNode.removeChild(this.element);
    } else {
	throw "template not found: " + id;
    }
};

Template.prototype = {

    expand: function(data) {
	var node = this.element.cloneNode(true);
	this.expandData(data, node);
	return node;
    },

    expandData: function(data, node) {
	switch (typeof data) {
	case 'string':
	case 'number':
	    node.innerHTML = data;
	    break;
	case 'object':
	    if (data.constructor == Array) {
		this.expandArray(data, node);
	    } else {
		this.expandObject(data, node);
	    }
	}
    },

    expandArray: function(data, node) {
	var parent = node.parentNode;
	parent.removeChild(node);
	for (var i = 0; i < data.length; i++) {
	    var child = node.cloneNode(true);
	    parent.appendChild(child);
	    this.expandData(data[i], child);
	}
    },

    cache: {},

    compile: function(str) {
	var len = str.length;
	var expr = false;
	var cmd = "";
	var lit = "";
	var out = [];

	for (var i = 0; i < len; i++) {
	    var c = str[i];

	    if (c == "'") {
		c = "\\'";
	    }

	    if (c == "\\") {
		c = "\\\\";
	    }

	    switch (c) {
	    case '{':
		expr = true;
		if (lit.length > 0) {
		    out.push("'" + lit + "'");
		}
		lit = "";
		break;
	    case '}':
		expr = false;
		out.push("(" + cmd + ")");
		cmd = "";
		break;
	    default:
		if (expr) {
		    cmd += c;
		} else {
		    lit += c;
		}
	    }
	}

	if (lit.length > 0) {
	    out.push("'" + lit + "'");
	}

	var code = '(function (data) { with (data) { return ' + out.join('+') + '; } })';

	return eval(code);
    },

    evaluate: function(str, data) {
	var fn = this.cache[str];
	if (!fn) {
	    fn = this.cache[str] = this.compile(str);
	}
	return fn(data);
    },

    expandObject: function(object, node) {
	var i, name;
	var attr = node.attributes;
	var nodes = node.childNodes;

	for (i = 0; i < attr.length; i++) {
	    var value = attr[i].value;
	    if (value.indexOf('{') != -1) {
		attr[i].value = this.evaluate(value, object);
	    }
	}

	for (i = 0; i < nodes.length; i++) {
	    var child = nodes[i];
	    if (child.nodeType == 1 && child.className[0] == '_') {
		this.expandData(object, child);
	    }
	    if (child.nodeType == 3 && child.nodeValue.indexOf('{') != -1)  {
		child.nodeValue = this.evaluate(child.nodeValue, object);
	    }
	}

	for (name in object) {
	    var child = node.getElementsByClassName(name)[0];
	    if (child) {
		this.expandData(object[name], child);
	    }
	}
    }
};

if (jQuery) {
    jQuery.fn.expand = function(template, data) {
	return this.html(template.expand(data));
    };
}
