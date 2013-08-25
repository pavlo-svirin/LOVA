Ext.define('Loto.controller.Games', {
    extend: 'Ext.app.Controller',
    views: [ 'Games' ],
    models: [ 'Game' ],
    stores: [ 'Games' ],
 
    init: function() {
        this.control({
            'games': {
                render: this._init
            },
            'games datefield': {
                change: this._refresh
            },
            'games button[action=refresh]': {
                click: this._refresh
            },
            'games button[action=game]': {
                click: this._game
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
      					url: "/admin/games/run/ajax/",
            		    method: 'POST',
      					params: {
          					luckyNumbers: lucky
      					},
                		success: function (result, request) {
            				debugger;
                			result = Ext.decode(result.responseText);
                			if(result.success) {
                				Ext.data.StoreManager.lookup('Games').load();
                			} else {
                		      	Ext.Msg.alert('Ошибка', result.message);
                			}
                		},
                		failure: function (result, request) {
                			debugger;
                		}
                	});            	   
      			}
            }
      	);    	
    }
});