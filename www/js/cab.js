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

function sendFirstEmail() {
	var me = this;
	$.ajax({
		url: "/cab/send/ajax/",
		dataType: 'json',
        success: function(data, status) {
        	$('#validateEmail')
        		.removeClass("alert-error")
        		.addClass("aler-success")
        		.html("Письмо со ссылкой было отправлено на почту.");
        }
	});
}

function toggleLotteryNumber(num) {
  var $href = $("#lottery_num_" + num).children("span");
  if(isNumSelected(num)) {
    removeNum(num);
    $href.removeClass("badge-success");
  } else if(countSelectedNumbers() >= config.maxNumbers) {
    alert("Вы выбрали максимальное количество номеров.");
  } else {
    addNum(num);
    $href.addClass("badge-success");
  }
  var selected = countSelectedNumbers();
  $("#count_selected_numbers").html(selected);
  if(selected == config.maxNumbers) {
	  $("#addTicketBtn").removeClass("disabled").removeAttr("disabled");
  } else {
	  $("#addTicketBtn").addClass("disabled").attr("disabled", "disabled");
  }
}

function countSelectedNumbers() {
  var numbers_list = $("input[name=selected_lottery_numbers]").val();
  if(numbers_list) {
    var numbers = numbers_list.split(",");
    return numbers.length;
  }
  return 0;
}

function isNumSelected(num) {
  if(!num) {
    return false;
  }
  var numbers_list = $("input[name=selected_lottery_numbers]").val();
  if(numbers_list) {
    var numbers = numbers_list.split(",");
    for(var i = 0; i < numbers.length; i++) {
      if(num == numbers[i]) {
        return true;
      }
    }
  }
  return false;
}

function addNum(num) {
  var numbers_list = $("input[name=selected_lottery_numbers]");
  if(numbers_list.val()) {
	  var numbers = numbers_list.val().split(",");
	  numbers.push(num);
	  numbers_list.val(numbers.join(","));
  } else {
	  numbers_list.val(num);
  }
}

function removeNum(num) {
	var numbers_list = $("input[name=selected_lottery_numbers]").val();
	if(numbers_list) {
		var numbers = numbers_list.split(",");
		for(var i = 0; i < numbers.length; i++) {
			if(num == numbers[i]) {
				numbers.splice(i, 1);
				break;
			}
		}
		$("input[name=selected_lottery_numbers]").val(numbers.join(","));
	}
}

function autoSelectNumbers() {
	$("input[name=selected_lottery_numbers]").val("");
	for(var i = 1; i <= config.maxNumber; i++) {
		$("#lottery_num_" + i).children("span").removeClass("badge-success");
	}
  
	var selectedNumbers = 0;
	while(selectedNumbers < config.maxNumbers) {
		var num = Math.floor((Math.random() * config.maxNumber) + 1);
		if(!isNumSelected(num)) {
			selectedNumbers++;
			addNum(num);
			$("#lottery_num_" + num).children("span").addClass("badge-success");
		}
	}
	
	$("#count_selected_numbers").html(countSelectedNumbers());
	$("#addTicketBtn").removeClass("disabled").removeAttr("disabled");
}  

function incGame() {
	var val = $("input[name=games_count]").val();
	if(isNaN(val) || val < 1) {
		val = 1;
	} else if(val < config.maxGames) {
		val++;
	} else {
		val = config.maxGames;
	}
	$("input[name=games_count]").val(val);
//  updateSum();
}

function decGame() {
	var val = $("input[name=games_count]").val();
	if(isNaN(val) || val <= 1) {
		val = 1;
	} else if(val <= config.maxGames) {
		val--;
	} else {
		val = config.maxGames;   
	}
	$("input[name=games_count]").val(val);
//  updateSum();
}

function incTickets() {
	var val = $("input[name=tickets_count]").val();
	if(isNaN(val) || val < 1) {
		val = 1;
	} else if(val < config.maxTickets) {
		val++;
	} else {
		val = config.maxTickets;
	}
	$("input[name=tickets_count]").val(val);
//  updateSum();
}

function decTickets() {
	var val = $("input[name=tickets_count]").val();
	if(isNaN(val) || val <= 1) {
		val = 1;
	} else if(val <= config.maxTickets) {
		val--;
	} else {
		val = config.maxTickets;   
	}
	$("input[name=tickets_count]").val(val);
//  updateSum();
}

function addTicket() {
	var selected = countSelectedNumbers();
	if(selected < config.maxNumbers) {
		alert("Вы выбрали не все числа. Осталось " + (config.maxNumbers - selected));
	} else if(selected == config.maxNumbers) {
		$("form[name=lottery]").attr("action", "/cab/ticket/add/").submit();
/*        $.ajax({
            type: "post",
            url: "/cab/ticket/add/ajax/",
            dataType: 'json',
            data: {
            	selected_lottery_numbers: $("input[name=selected_lottery_numbers]").val(),
            	games_count: $("input[name=games_count]").val()
            },
            error: function(data, status) {
				alert("Произошла ошибка, попробуйте позже.");
				// send log
            },
            success: function(data, status) {
            	// $form.find("button[name='invite']") 
            	//	.removeClass("disabled")
            	//	.removeAttr("disabled");
            	debugger;
    			if(data.success) {
    			} else {
    				
    			}
            }
        });*/
	}
}
