jQuery.fn.extend({
	jCountdown:function(){
		var Slide = function(target){
			//---------------------------------------------------------------------------------------
			//vars
			//---------------------------------------------------------------------------------------
			this._target = target;
			this._width = 50;
			this._height = 64;
			this._frame = 1;
			this._totalFrames = 15;
			this._fps = 24;
			this._intervalId = -1;
			this._value = 0;
			this._tagetValue = 0;
			
			//---------------------------------------------------------------------------------------
			//methods
			//---------------------------------------------------------------------------------------
			this.stop = function(){
				clearInterval(this._intervalId);
			}
			
			this.update = function(flag){
				if(flag) {
					this.frame(1);
					
					this.stop();
					
					var target = this;
					this._intervalId = setInterval(function(){
						if(target.frame()==target.totalFrames()){
							clearInterval(target._intervalId);
							target.onFinish();
						}else{
							target.frame(target.frame()+1);
						}
					},Math.ceil(1000/this.fps()));
				} else {
					this.frame(this.totalFrames());
				}
			}
			
			this.value = function(v, flag) {
				if (v == undefined) {
					return this._value;
				} else {
					if(this._value == v)
					{
						this.update()
						return;
					}
					if (flag) {
						var cur = (this._value > 0) ? this._value : 10;
						// simple countdown 
						if(v == cur - 1)
						{
							this._value = v;
							this.update(true);
						}
						else
						{
							this._targetValue = v;
							this._value = (this._value > 0) ? this._value - 1 : 9;
							this.update(true);
						}
					} else {
						this._value = v;
						this.update();
					}
				}
			}
			
			this.onFinish = function(){
				if(this._targetValue != null)
				{
					if(this._targetValue == this._value)
					{
						this._targetValue = null;
					}
					else
					{
						this._value = (this._value > 0) ? this._value - 1 : 9;
						this.update(true);
					}
				}
			}

			this.destroy = function(){
				this.stop();
				this._target = null;
			}

			//---------------------------------------------------------------------------------------
			//properties
			//---------------------------------------------------------------------------------------					
			this.width = function(v){
				if(v==undefined){
					return this._width;
				}else{
					this._width = v;
				}
			}
					
			this.height  = function(v){
				if(v==undefined){
					return this._height ;
				}else{
					this._height  = v;
				}
			}
			
			this.frame = function(v){
				if(v==undefined){
					return this._frame;
				}else{
					this._frame = v;
					var left = 0;
					var top = -((1+this.value())*this.height()) + (Math.sin((this.frame()-1)/(this.totalFrames()-1)*Math.PI/2)*this.height());
					this._target.children(".text").css("background-position", left+"px"+" "+top+"px");
				}
			}

			this.totalFrames = function(v){
				if(v==undefined){
					return this._totalFrames;
				}else{
					this._totalFrames = v;
				}
			}

			this.fps = function(v){
				if(v==undefined){
					return this._fps;
				}else{
					this._fps = v;
				}
			}

			//---------------------------------------------------------------------------------------
			//init
			//---------------------------------------------------------------------------------------
			this.update(false);
		}

		
		var Countdown = function(){
			//---------------------------------------------------------------------------------------
			//vars
			//---------------------------------------------------------------------------------------
			this._days = [];
			this._tickId = -1;
			this._tickDelay = 10000;
			this._tickCount = 0;

			//---------------------------------------------------------------------------------------
			//methods
			//---------------------------------------------------------------------------------------

			//start
			this.start = function(){
				this.stop();
				for(var i=0; i<this._days.length; i++){
					this._days[i].update();
				}
				var me = this;
				this._tickId = setInterval(function(){ me.refresh(me) }, me._tickDelay);				
			}
			
			this.refresh = function(me) {
				me._tickCount++;
				$.ajax({
					url: "/cab/countdown/ajax/",
					dataType: 'json',
			        success: function(data, status) {
			        	me.update('' + data.counter, 'sync');
			        }
				});
				
				if(this._tickCount == 60) {
					clearInterval(this._tickId);
					me._tickDelay = 20000;
					me._tickId = setInterval(function(){ me.refresh(me) }, me._tickDelay);				
				} else if (me._tickCount == 90) {
					clearInterval(this._tickId);
					me._tickDelay = 60000;
					me._tickId = setInterval(function(){ me.refresh(me) }, me._tickDelay);				
				} else if (this._tickCount == 120) {
					clearInterval(this._tickId);
					me._tickDelay = 120000;
					me._tickId = setInterval(function(){ me.refresh(me) }, me._tickDelay);				
				}
				else if (me._tickCount == 150) {
					clearInterval(me._tickId);
					me._tickDelay = 300000;
					me._tickId = setInterval(function(){ me.refresh(me) }, me._tickDelay);				
				}
				else if (me._tickCount > 180) {
					clearInterval(me._tickId);
				}
			}
			
			//stop
			this.stop = function(){
				for(var i=0; i<this._days.length; i++){
					this._days[i].stop();
				}				
				clearInterval(this._tickId);
			}
			
			this.onFinish = function(){
			}

			this.destroy = function(){
				for(var i=0; i<this._days.length; i++){
					this._days[i].destroy();
				}				

				this._days = [];

				this.stop();
			}

			//---------------------------------------------------------------------------------------
			//properties
			//---------------------------------------------------------------------------------------	
			this.items = function(days){
				this._days = days;
			}
			
			// update
			this.update = function(val, flag){
				var counter = this._days.length;
				var sync = (flag == "sync" ) ? true : false;
				for(var i = val.length - 1; i >= 0; i--)
				{
					counter--;
					this._days[counter].value(parseInt(val[i], 10), sync);
				}
				while(counter > 0)
				{
					counter--;
					this._days[counter].value(0, sync);
				}
			}
			
			//---------------------------------------------------------------------------------------
			//init
			//---------------------------------------------------------------------------------------
		}

		//---------------------------------------------------------------------------------------
		//init
		//---------------------------------------------------------------------------------------
		var getCountdown = function(){
			return target.data("countdown");
		}
		var initCountdown = function(){
			if(getCountdown()==undefined){
				var countdown = new Countdown();
				target.data("countdown", countdown);
				
				return getCountdown();
			}
		}
		var destroyCountdown = function(){
			if(getCountdown()!=undefined){
				getCountdown().destroy();

				target.removeData("countdown");
			}
		}
		var init = function(setting){
			countdown = initCountdown();
				
			var browserVersion = parseInt(jQuery.browser.version,10);
			
			var style = "slide";
			var color = "white";

			var width = parseInt(setting.width,10);
			if(width>=10){
			}else{
				width = 0;
			}
			var textGroupSpace = parseInt(setting.textGroupSpace,10);
			if(textGroupSpace>=0){
			}else{
				textGroupSpace = 15;
			}			
			var textSpace = parseInt(setting.textSpace,10);
			if(textSpace>0){
			}else{
				textSpace = 0;
			}			
			var reflection = setting.reflection!=false;
			var reflectionOpacity = parseFloat(setting.reflectionOpacity);
			if(reflectionOpacity>0){
				if(reflectionOpacity>100){
					reflectionOpacity = 100;
				}
			}else{
				reflectionOpacity = 10;
			}			
			var reflectionBlur = parseInt(setting.reflectionBlur,10);
			if(reflectionBlur>0){
				if(reflectionBlur>10){
					reflectionBlur = 10;
				}
			}else{
				reflectionBlur = 0;
			}			
			var dayTextNumber = parseInt(setting.dayTextNumber,10)>2 ? parseInt(setting.dayTextNumber,10) : 2;

			var html = "";
			var itemClass = "";
			var lastClass = "";

			html += '<div class="jCountdown">';
			
			var lastItem = " lastItem";
			html += '<div class="group day lastItem">';
			for ( var i = 0; i < dayTextNumber; i++ ) {
				itemClass = " item" + (i + 1);
				lastClass = i==(dayTextNumber-1) ? " lastItem" : "";
				html += '<div class="container'+itemClass+lastClass+'">';
				if(style=="slide" || style=="crystal" || style=="metal") {
					html += '<div class="cover"></div>';
				}
				html += '<div class="text"></div>';
				html += '</div>';
			}
			
			html += '<div class="label"></div>';
			html += '</div>';
			html += '</div>';
			
			target.html(html);

			var countdownObject = target.children(".jCountdown");

			countdownObject.addClass(style);
			countdownObject.addClass(color);
			
			countdownObject.children(".group").css("margin-right",textGroupSpace+"px");
			countdownObject.children(".group.lastItem").css("margin-right","0px");
			countdownObject.children(".group").children(".container").css("margin-right",textSpace+"px");
			countdownObject.children(".group").children(".container.lastItem").css("margin-right","0px");
			
			if(reflection){
				if((jQuery.browser.msie && browserVersion < 10)) {
				} else {
					reflectionObject = countdownObject.clone();
	
					reflectionObject.addClass("reflection");
					reflectionObject.addClass("displayLabel");
					
					if(reflectionOpacity!=100){
						reflectionObject.css("opacity",reflectionOpacity/100);
					}
					if(reflectionBlur!=0){
						reflectionObject.addClass("blur"+reflectionBlur);
					}
					
					countdownObject = countdownObject.add(reflectionObject);
				}
			}

			var countdownContainer = jQuery('<div class="jCountdownContainer"></div>');
			countdownContainer.append(countdownObject);

			target.append(countdownContainer);
			
			if(width!=0){
				var countdownScaleObject = jQuery('<div class="jCountdownScale"></div>');
				countdownScaleObject.append(countdownObject);
				
				countdownContainer.append(countdownScaleObject);
				
				var countdownScaleObjectWidth = countdownScaleObject.width();
				var countdownScaleObjectHeight = countdownScaleObject.height();
				
				var scale = width/countdownScaleObjectWidth;
				var left = -(1-scale)*countdownScaleObjectWidth/2;
				var top = -(1-scale)*countdownScaleObjectHeight/2;
				var scaleCss = "scale("+scale+")";
				
				countdownContainer.width(countdownScaleObjectWidth*scale);
				countdownContainer.height(countdownScaleObjectHeight*scale);
				
				if(jQuery.browser.msie && browserVersion<=8){
					countdownScaleObject.css("zoom", scale);
				}else{
					countdownScaleObject.css("transform", scaleCss).
					css("-moz-transform", scaleCss).
					css("-webkit-transform", scaleCss).
					css("-o-transform", scaleCss).
					css("-ms-transform", scaleCss);
					
					countdownScaleObject.css("left",left).css("top",top);
				}
			}

			var selector = "";
			var index = 0;
			var days = [];
			var itemClass = function(){};

			itemClass = Slide;

			index = 1;
			selector = ".group.day>.container.item";
			while(countdownObject.find(selector+index).length){
				days.push(new itemClass(countdownObject.find(selector+index)));
				index++;
			};
			
			countdown.items(days);
		}
		var destroy = function(){
			destroyCountdown();
			target.children().remove();
		}
		var start = function(){
			countdown.start();
		}
		var stop = function(){
			countdown.stop();
		}
		var update = function(val, flag){
			countdown.update(val, flag);
		}

		if(arguments.length>0){
			var target = this;
			var countdown = getCountdown();

			if(arguments.length==1 && typeof(arguments[0])=="object"){
				//destroy the old countdown
				if(countdown!=undefined){
					destroy();
				}

				//init new countdown
				init(arguments[0]);
			}else if(typeof(arguments[0])=="string"){
				//set setting & call method
				if(countdown!=undefined){
					switch(arguments[0]){
						case "stop":
							stop();
							break;
						case "start":
							start();
							break;
						case "update":
							update(arguments[1], arguments[2]);
							break;
						case "destroy":
							destroy();
							break;
						default:
					}
				}
			}
		}

		return this;
	}
});