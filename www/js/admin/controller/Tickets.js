Ext.define('Loto.controller.Tickets', {
    extend: 'Ext.app.Controller',
    views: [ 'Tickets' ],
    models: [ 'Ticket' ],
    stores: [ 'Tickets' ],
 
    init: function() {
        this.control({
            'tickets': {
                render: this._init
            },
            'tickets datefield': {
                change: this._refresh
            },
            'tickets checkbox': {
                change: this._refresh
            },
            'tickets button[action=refresh]': {
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
        var store = Ext.data.StoreManager.lookup('Tickets');

    	var from = widget.down("datefield[name=from]").getValue();
    	var to = widget.down("datefield[name=to]").getValue();
    	var paid = widget.down("checkbox[name=paid]").getValue();
    	var active = widget.down("checkbox[name=active]").getValue();
    	
    	if(from && to && !store.isLoading()) {
    		store.getProxy().extraParams = {
                from: Ext.Date.format(from, 'Y-m-d'),
                to: Ext.Date.format(to, 'Y-m-d'),
                paid: (paid) ? paid : null,
                active: (active) ? active : null
    		};
    		
    		store.load();
    	}
    	
    },
    
});