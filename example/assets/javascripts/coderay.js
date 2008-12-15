
$('pre.highlight').each(function() {
    var pre = $(this);
    var text = $('li', pre).map(function() { return $(this).text(); }).get();
    var textarea = $('<textarea class="code-area" cols="80" rows="' + text.length + ' ">' + text.join("\n") + '</textarea>');
    var div = $('<div class="code-link"><a href="#">View plain</a></div>').insertBefore(pre);
    var toggle = false;
    $('a', div).click(function() {
	toggle ? textarea.replaceWith(pre) : pre.replaceWith(textarea);
	toggle = !toggle;
	return false;
    });
});
