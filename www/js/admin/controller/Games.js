Ext.define('Loto.controller.Games', {
    extend: 'Ext.app.Controller',
    views: [ 'Games', 'GameDetails' ],
    models: [ 'Game' ],
    stores: [ 'Games' ],
 
    init: function() {
        this.control({
            'games': {
                render: this._init,
            	selectionchange: this._select
            },
            'games datefield': {
                change: this._refresh
            },
            'games button[action=refresh]': {
                click: this._refresh
            },
            'games button[action=game]': {
                click: this._game
            },
            'gameDetails button[action=close]': {
                click: this._close
            },
            'gameDetails button[action=approve]': {
                click: this._approve
            },
            'gameDetails fieldset[id=budget] sliderfield': {
                change: this._ballanceSliders
            },
            'gameDetails fieldset[id=prize] sliderfield': {
                change: this._ballancePrizeSliders
            }
            
        });
    },
    
    _init: function(widget)
    {
        widget.down("datefield[name=from]").setValue(Ext.Date.getFirstDateOfMonth(new Date()));
        widget.down("datefield[name=to]").setValue(Ext.Date.getLastDateOfMonth(new Date()));
        this._refresh(widget.down("button[action=refresh]"));
    },
   
    _refresh: function(source)
    {
    	var widget = source.up("panel");
 
    	var from = widget.down("datefield[name=from]").getValue();
    	var to = widget.down("datefield[name=to]").getValue();

        var store = Ext.data.StoreManager.lookup('Games');    	
    	if(from && to && !store.isLoading()) {
            store.load({
                params: {
                    from: Ext.Date.format(from, 'Y-m-d'),
                    to: Ext.Date.format(to, 'Y-m-d')
                }        	
            });
		}
    },

    _select: function(selection, rows)
    {
        var game = selection.selected.first();
        if(game) {
            var details = selection.view.up("tabpanel").down("gameDetails");
            details.show();
            details.getForm().loadRecord(game);
            
            details.down('grid[id=winnerTickets]').reconfigure(game.winner_tickets());
            
            if(game.get('approved')) {
            	details.down('button[action=approve]').disable();
            	
	            // load sliders from budget            	
            	var sliders = details.down('fieldset[id=budget]').query('sliderfield');
	            for (var i = 0; i < sliders.length; i++) {
	            	var slider = sliders[i]; 
	            	slider.disable();
	                var budget = slider.name.toLowerCase().replace("budget", "");
	                var value = game.get('budget.' + budget) || 0;
	                var labels = slider.up("fieldset").query("label[name='" + slider.name + "']");
	            	labels[0].update('$' + value);
	            }
           	
	            // disable winner sliders
	            details.down('fieldset[id=prize]').hide();

            } else {
            	details.down('button[action=approve]').enable();
            	
	            var options = selection.view.up("tabpanel").down("options");
	            var sliders = options.query('sliderfield');
	            for (var i = 0; i < sliders.length; i++) {
	            	var name = sliders[i].getName();
	            	var val = sliders[i].thumbs[0].value;
	            	var slider = details.down('fieldset[id=budget]').down('sliderfield[name=' + name +']');
	            	slider.enable();
	               	slider.setValue(val);
	            	slider.syncThumbs();
	            	this._ballanceSliders(slider);
	            }
	            
	            // enable winner sliders
	            details.down('fieldset[id=prize]').show();
	            
            }
        }
    },

    _close: function(btn)
    {
    	btn.up("tabpanel").down("games").getSelectionModel().deselectAll();
        var details = btn.up("tabpanel").down("gameDetails");
        details.getForm().reset();
        details.hide();
    },
    
    _game: function(source)
    {
    	var msg = "Вы уверены что хотите произвести розыгрыш сейчас?"; 
    	var lucky = source.up('tabpanel').down('options').down('textfield[name=luckyNumbers]').getValue();
    	if(!lucky) {
    		msg = msg + "<br>Выигрышные числа не выбраны!";
    	}
      	Ext.Msg.confirm('Розыгрыш',
      	    msg,
  			function (btn){
      			if(btn == 'yes') {
      				Ext.Ajax.request({
      					url: "/admin/game/run/ajax/",
            		    method: 'POST',
      					params: {
          					luckyNumbers: lucky
      					},
                		success: function (result, request) {
                			result = Ext.decode(result.responseText);
                			if(result.success) {
	            		      	Ext.Msg.alert('Проведение розыгрыша', 'Розыгрыш проведен успешно');                				
                				Ext.data.StoreManager.lookup('Games').load();
                			} else {
                		      	Ext.Msg.alert('Ошибка', result.message);
                			}
                		},
                		failure: function (result, request) {
                		}
                	});            	   
      			}
            }
      	);    	
    },
    
    _approve: function(source)
    {
    	var self = this;
    	var msg = "Вы уверены что хотите подтвердить розыгрыш?"; 
      	Ext.Msg.confirm('Розыгрыш',
      	    msg,
  			function (btn){
	  			if(btn == 'yes') {
	  				var approveParams = new Object;
	  	            var details = source.up("tabpanel").down("gameDetails");
	  	            var game = details.getRecord();
	  				approveParams.gameId = game.get('id');
	  				var sliders = details.query('sliderfield');
		            for (var i = 0; i < sliders.length; i++) {
		            	var name = sliders[i].getName();
		            	var val = sliders[i].thumbs[0].value;
		            	approveParams[name] = val;
		            }	  				
	  				Ext.Ajax.request({
	  					url: "/admin/game/approve/ajax/",
	        		    method: 'POST',
	  					params: approveParams,
	            		success: function (result, request) {
	            			result = Ext.decode(result.responseText);
	            			if(result.success) {
	            		      	Ext.Msg.alert('Подтверждение розыгрыша', 'Розыгрыш подтвержден успешно');
	            				Ext.data.StoreManager.lookup('Games').load();
	            				self._close(source);
	            			} else {
	            		      	Ext.Msg.alert('Ошибка', result.message);
	            			}
	            		},
	            		failure: function (response, request) {
            		      	Ext.Msg.alert('Ошибка', response.responseText);
	            		}
	            	});            	   
	  			}
	        }
	  	);    	
    },
    
    _ballanceSliders: function(slider)
    {
        var sliders = slider.up("fieldset").query("sliderfield");
        sliders = Ext.Array.remove(sliders, slider);
        var currentSlider = slider.thumbs[0].value;
        var otherSliders = this._sumSliders(sliders);
        if ((otherSliders + currentSlider) > 100) {
        	slider.setValue(100 - otherSliders)
        	slider.syncThumbs();
        }
        var labels = slider.up("fieldset").query("label[name='" + slider.name + "']");
        if (labels && labels.length > 0) {
        	var percents = String(slider.thumbs[0].value) + '%';
            var details = slider.up("tabpanel").down("gameDetails");
            var game = details.getRecord();
            var value = game.get('sum') * slider.thumbs[0].value * 0.01;
        	labels[0].update('$' + value.toFixed(2) + ' (' + percents + ')');
        }
    },
      
    _sumSliders: function(sliders)
    {
        var total = 0;
        for(var i = 0; i < sliders.length; i++) {
        	if(!isNaN(sliders[i].thumbs[0].value)) {
        		total += sliders[i].thumbs[0].value;
        	}
        }
        return total;
    },
    
    _ballancePrizeSliders: function(slider)
    {
        var sliders = slider.up("fieldset").query("sliderfield");
        sliders = Ext.Array.remove(sliders, slider);
        var currentSlider = slider.thumbs[0].value;
        var otherSliders = this._sumSliders(sliders);
        if ((otherSliders + currentSlider) > 100) {
        	slider.setValue(100 - otherSliders)
        	slider.syncThumbs();
        }
        var labels = slider.up("fieldset").query("label[name='" + slider.name + "']");
        if (labels && labels.length > 0) {
        	var percents = String(slider.thumbs[0].value) + '%';
            var details = slider.up("tabpanel").down("gameDetails");
            var game = details.getRecord();
            var totalPrizeSlider = details.down('fieldset[id=budget]').down('sliderfield[name=budgetPrize]');
            var totalPrize = game.get('sum') * 0.01 * totalPrizeSlider.thumbs[0].value;
            var value = totalPrize * slider.thumbs[0].value * 0.01;
        	labels[0].update('$' + value.toFixed(2) + ' (' + percents + ')');
        }
    }
    
});