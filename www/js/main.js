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
    				top.location = "/cab/";
    				// alert("Регистрация прошла успешно.");
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

    $('#profileForm').on('submit', function(event) {
    	
        var $form = $(this);
        
        // disable register button;
    	var $btn = $form.find("button[name='save']"); 
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
            	var $btn = $form.find("button[name='save']"); 
            	$btn.removeClass("disabled");
            	$btn.removeAttr("disabled");
				alert("Произошла ошибка, попробуйте позже.");
            },
            success: function(data, status) {
            	// enable register button
            	var $btn = $form.find("button[name='save']"); 
            	$btn.removeClass("disabled");
            	$btn.removeAttr("disabled");
            	
    			if(data.success === "true")
    			{
    				alert("Настройки сохранены.");
    			}
    			else
    			{
    				for(field in data.fields)
    				{
    					$("#profileForm")
    						.find("input[name='" + field + "']")
    						.closest('.control-group')
    						.addClass('error');
    					$("#profileForm")
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

    $('.network-icons a').on('click', function(event) {
    	$('div#alert').removeClass("alert-error");
    	$('div#alert').addClass("alert-success");
    	$('div#alert').html("Вы использовали все возможности кабинета! :-)");
    	$.ajax("/like/ajax/");
    });
    
    var vk = VK.Share.button({ url: 'http://lova.su', title: 'LoVa'}, { type: 'link',  text: ''});
    
});


