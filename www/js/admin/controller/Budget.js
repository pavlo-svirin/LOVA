Ext.define('Loto.controller.Budget', {
    extend: 'Ext.app.Controller',
    views: [ 'Budget' ],
    models: [ 'Budget' ],
    stores: [ 'Budget' ],
 
    init: function() {
        this.control({
            'budget': {
                render: this._init
            },
            'budget datefield': {
                change: this._refresh
            },
            'budget button[action=refresh]': {
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

        var store = Ext.data.StoreManager.lookup('Budget');    	
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