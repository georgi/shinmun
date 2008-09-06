function override(origclass, overrides) {
    if(overrides) {
        var p = origclass.prototype;
        for(var method in overrides){
            p[method] = overrides[method];
        }
    }
}

Enumerable = {

    index : function(fn, self) {
        fn = fn.toFunction();
        var result = -1;
        this.each(
            function(item, index) {
	        if (fn.call(self, item, index)) {
	            result = index;
	            return false;
	        }
		else {
		    return true;
		}
            }
        );
        return result;
    },

    map : function(fn, self) {
        fn = fn.toFunction();
        var res = [];
        this.each(
            function(item, index) {
	        res.push(fn.call(self, item, index));
            }
        );
        return res;
    },

    every : function(fn, self) {
        fn = fn.toFunction();
        var result = true;
        var len = this.length;
        this.each(
            function(item, index) {
	        if (!fn.call(self, item, index)) {
	            result = false;
	        }
            });
        return result;
    },

    some : function(fn, self) {
        return this.find(fn, self) != null;
    },

    filter : function(fn, self) {
        fn = fn.toFunction();
        var result = [];
        this.each(
            function(item, index) {
	        if (fn.call(self, item, index)) {
	            result.push(item);
	        }
            }
        );
        return result;
    },

    reject : function(fn, self) {
        fn = fn.toFunction();
        return this.filter(
            function(item, index) {
	        return !fn.call(self, item, index);
            }
        );
    },

    grep : function(regex) {
        return this.filter(
            function(item) {
	        return regex.test(item);
            }
        );
    },

    compact : function() {
        return this.filter(
            function(item) {
	        return item !== null && item !== undefined;
            }
        );
    },

    uniq : function() {
        return this.inject(
            [],
            function(result, item) {
	        if (!result.includes(item)) {
	            result.push(item);
	        }
	        return result;
            }
        );
    },

    partition : function(fn, self) {
        fn = fn.toFunction();

        var positives = [];
        var negatives = [];

        this.each(
            function(item, index) {
	        if (fn.call(self, item, index)) {
	            positives.push(item);
	        } else {
	            negatives.push(item);
	        }
            }
        );

        return [positives, negatives];
    },

    indexBy : function(fn, self) {
        fn = fn.toFunction();
        var hash = {};
        this.each(
            function(item, index) {
	        var key = fn.call(self, item, index).toString();
	        if (!hash[key]) hash[key] = [];
	        hash[key].push(item);
            }
        );
        return hash;
    },

    groupBy : function(fn, self) {
        fn = fn.toFunction();
        var hash = this.indexBy(fn);
        var result = [];
        for (var name in hash) {
            result = result.concat([hash[name]]);
        }
        return result;
    },

    inject : function(value, fn, self) {
        fn = fn.toFunction();
        this.each(
            function(item, index) {
	        value = fn.call(self, value, item, index);
	    }
        );
        return value;
    },

    sum: function(fn, self) {
        fn = fn.toFunction();
        return this.inject(0, function(value, item, index) {
            return value + fn.call(self, item, index);
        }, self);
    },

    indexOf : function(value) {
        var result = -1;
        this.each(
            function(item, index) {
	        if (equals(item, value)) {
		    result = index;
		    return false;
	        }
		else {
		    return true;
		}
	    }
        );
        return result;
    },

    includes : function(value) {
        return this.indexOf(value) != -1;
    },

    find : function(fn, self) {
        fn = fn.toFunction();
        var result = null;
        this.each(
            function(item, index) {
	        if (fn.call(self, item, index)) {
		    result = item;
		    return false;
	        }
		else {
		    return true;
		}
	    }
        );
        return result;
    },

    findBy : function(property, value) {
        var result = null;
        this.each(
            function(item) {
	        if (item[property] == value) {
		    result = item;
		    return false;
	        }
		else {
		    return true;
		}
	    }
        );
        return result;
    },

    sortBy : function(fn, self) {
        return this.map(
            function(item, index) {
	        return [fn.call(self, item, index), item];
	    }
        ).sort().map(
            function(item) {
	        return item[1];
	    }
        );
    }
};

override(Array, Enumerable);

Array.prototype._sort = Array.prototype.sort;

override(Array, {

    each : function(fn, self) {
	fn = fn.toFunction();
	var len = this.length;
	for (var i = 0;i < len; i++) {
	    if (fn.call(self, this[i], i) === false) {
		break;
	    }
	}
	return this;
    },

    remove : function(value) {
	var result = null;
	this.each(function(item, index) {
	    if (equals(item, value)) {
		this.splice(index, 1);
		return false;
	    } else {
		return true;
	    }
	}, this);
	return this;
    },

    deleteIf : function(fn, self) {
	var indexes = [];
	this.each(function(item, index) {
	    if (fn.call(self, item, index)) {
		indexes.push(index);
	    }
	}, this);
	indexes.reverse().each(function(index) {
	    this.splice(index, 1);
	}, this);
	return this;
    },

    clone : function() {
	return [].concat(this);
    },

    equals : function(other) {
	if (other == null || this.constructor != other.constructor
	    || this.length != other.length) {
	    return false;
	}
	var len = this.length;
	for (var i = 0;i < len; i++) {
	    if (!equals(this[i], other[i])) {
		return false;
	    }
	}
	return true;
    },

    first : function() {
	return this[0];
    },

    last : function() {
	return this[this.length - 1];
    },

    max : function() {
	return this.sort().last();
    },

    min : function() {
	return this.sort().first();
    }

});

override(Date, {

    until: function(date) {
	var result = [];
	var cur = this;
	var end = date.getTime();

	while (cur.getTime() < end) {
	    result.push(cur);
	    cur = cur.add(Date.DAY, 1);
	}

	return result;
    }

});

override(String, {

    equals : function(other) {
	return this == other;
    },

    clone : function() {
	return new String(this);
    },

    toArray : function() {
	return this.split("\n");
    }

});

override(Number, {

    equals : function(other) {
	return this == other;
    },

    clone : function(other) {
	return this;
    },

    times : function(fn, self) {
	for (var i = 0;i < this; i++) {
	    fn.call(self, i);
	}
    }
});

function equals(a, b) {
    if (a && a.equals)
        return a.equals(b);
    return a == b;
}
