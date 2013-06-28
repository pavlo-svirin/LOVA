jQuery(function($) {

    $('#inviteForm').on('submit', function(event) {
    	
        var $form = $(this);
        
        // disable register button;
    	$form.find("button[name='invite']") 
    		.addClass("disabled")
    		.attr("disabled", "disabled");        
 
    	// flush errors
		$form.find("div.alert-error").addClass("hide");
		$form.find("div.alert-success").addClass("hide");
    	
        $.ajax({
            type: $form.attr('method'),
            url: $form.attr('action') + "/ajax/",
            data: $form.serialize(),
            dataType: 'json',
            error: function(data, status) {
            	// enable register button
            	$form.find("button[name='invite']") 
            		.removeClass("disabled")
            		.removeAttr("disabled");
            	
				$form.find("div.alert-success").addClass("hide");
				$form.find("div.alert-error").removeClass("hide");
				$form.find("div.alert-error").html("Произошла ошибка, попробуйте позже.");
            },
            success: function(data, status) {
            	// enable register button
            	$form.find("button[name='invite']") 
            		.removeClass("disabled")
            		.removeAttr("disabled");
            	
    			if(data.success)
    			{
    				$form.find("div.alert-error").addClass("hide");
    				$form.find("div.alert-success").removeClass("hide");
                	$form.find("input").val(""); 
    			}
    			else
    			{
    				$form.find("div.alert-error").html(data.error);
    				$form.find("div.alert-success").addClass("hide");
    				$form.find("div.alert-error").removeClass("hide");
    			}
            }
        });
 
        event.preventDefault();
    });

    
});

