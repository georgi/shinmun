$('.comment-form form').ajaxForm({
    url: Blog.root + 'controllers/comments.php',
    type: 'POST',
    resetForm: true,
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

function renderComments(data) {
    var converter = new Showdown.converter();
    var lines = data.split("\n");
    var comments = [];
    for (var i = 0; i < lines.length; i++) {
	var row = eval(lines[i]);
	if (row) {
	    comments.push({
		time: row[0],
		name: row[1],
		website: row[2],
		text: converter.makeHtml(row[3])
	    });
	}
    }
    $('.comments-loading').hide();
    $('.comments').expand(Template.comments, { comment: comments });
    $('.comments a').prettyDate();
}

function loadComments() {
    $('.comments-loading').show();
    $.ajax({
	type: "GET",
	url: Blog.root + 'controllers/comments.php',
	data: {
	    guid: Blog.guid
	},
	complete: function(response) {
	    renderComments(response.responseText);
	}
    });
}

$(function() {
    if ($('.comments').length > 0) {
	Template.comments = new Template('comments-template');
	loadComments();
    }
});