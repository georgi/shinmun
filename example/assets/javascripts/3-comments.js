(function() {
    function submit(preview) {
	$('.comment-form form').ajaxSubmit({
	    url: '/comments',
	    type: 'POST',
	    data: {
		preview: preview
	    },
	    resetForm: !preview,
	    beforeSubmit: function(values) {
		if (values[1].value && values[3].value) {
		    $('.comment-form .loading').show();
		    return true;
		}
		else {
		    alert('Please enter name and text!');
		    return false;
		}
	    },
	    success: function(data) {
		$('.comment-form .loading').hide();
		if (preview) {
		    $('.comment-form .preview').html(data);
		    $('.preview-header').show();
		}
		else {
		    $('.preview-header').hide();
		    $('.comment-form .preview').html('');
		    $('.comments').html(data);
		}
	    }
	});
    }

    $('.comment-form form').submit(function() {
	submit(false);
	return false;
    });

    $('.comment-form .preview-button').click(function() {
	submit(true);
	return false;
    });

})();