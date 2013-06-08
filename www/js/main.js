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

function fbShare()
{
    window.open("https://www.facebook.com/sharer/sharer.php?u=lova.su", 'sharer', 'width=626,height=436');
    return false;
}

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
    	$.ajax("/like/ajax/");
    	$('div#alert').addClass("ajax-loading");

    	setTimeout(function(){
    		$('div#alert')
    			.removeClass("alert-error")
    			.removeClass("ajax-loading")
    			.addClass("alert-success")
        		.html("Вы использовали все возможности кабинета! :-)");
    	}, 20000);
    });
    
    var vk = VK.Share.button({ url: 'http://lova.su', title: 'LoVa', image: 'http://lova.su/img/logo.jpg'}, { type: 'link',  text: ''});
    
});


