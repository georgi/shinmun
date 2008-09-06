$('.comment-form form').ajaxForm({
    url: Blog.root + 'controllers/comments.php',
    type: 'POST',
    target: '.comments',
    beforeSubmit: function(values) {
	if (values[1].value && values[3].value) {
            $('.comment-form-loading').show();
	    return true;
	}
	else {
	    alert('Please enter name and text!');
	    return false;
	}
    },
    success: function(data) {
        $('.comment-form-loading').hide();
	renderComments(data);
    }
});

Template.comments = new Template('comments-template');

function renderComments(data) {
    var comments = data.split("\n").map(eval).map(function(row) {
	return row ? {
	    time: row[0],
	    name: row[1],
	    website: row[2],
	    text: row[3]
	} : null;
    }).compact();
    $('.comments-loading').hide();
    $('.comments').expand(Template.comments, { comment: comments });
    $('.comments a').prettyDate();
}

function loadComments(guid) {
    $('.comments-loading').show();
    $.ajax({
	type: "GET",
	url: Blog.root + 'controllers/comments.php',
	data: {
	    guid: guid
	},
	complete: function(response) {
	    renderComments(response.responseText);
	}
    });
}

$(function() {
    loadComments(Blog.guid);
});