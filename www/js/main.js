function loginAction()
{
	var loginForm = document.getElementById('loginForm');
	if(loginForm)
	{
		if(loginForm.style.visibility == 'hidden')
		{
			loginForm.style.visibility = 'visible';
		}
		else
		{
			loginForm.submit();
		}
	}
}

// Registration
jQuery(function($) {
    $('#registerForm').on('submit', function(event) {
    	
        var $form = $(this);
        
        // disable register button;
    	var $btn = $form.find("button[name='register']"); 
    	$btn.addClass("disabled");
    	$btn.attr("disabled", "disabled");        
 
    	// flush errors
    	$form.find("input")
			.closest('.control-group')
			.removeClass('error');
    	$form.find("input")
			.parent()
			.children("span")
			.html("");
    	
        $.ajax({
            type: $form.attr('method'),
            url: $form.attr('action') + "/ajax/",
            data: $form.serialize(),
            dataType: 'json',
            error: function(data, status) {
            	// enable register button
            	var $btn = $form.find("button[name='register']"); 
            	$btn.removeClass("disabled");
            	$btn.removeAttr("disabled");
				alert("Произошла ошибка, попробуйте позже.");
            },
            success: function(data, status) {
            	// enable register button
            	var $btn = $form.find("button[name='register']"); 
            	$btn.removeClass("disabled");
            	$btn.removeAttr("disabled");
            	
    			if(data.success === "true")
    			{
    				alert("Регистрация прошла успешно.");
    			}
    			else
    			{
    				for(field in data.fields)
    				{
    					$("#registerForm")
    						.find("input[name='" + field + "']")
    						.closest('.control-group')
    						.addClass('error');
    					$("#registerForm")
    						.find("input[name='" + field + "']")
    						.parent()
    						.children("span")
    						.html(data.fields[field]);
    				}
    			}
            }
        });
 
        event.preventDefault();
    });
});


