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
    
});