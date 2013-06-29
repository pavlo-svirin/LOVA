Ext.define('Loto.controller.Users', {
    extend: 'Ext.app.Controller',
    views: [ 'Users', 'UsersChart' ],
    models: [ 'User', 'Registrations' ],
    stores: [ 'User', 'Registrations' ],

    init: function() {
        this.control({
            'usersChart': {
                render: this._init
            },
            'usersChart datefield': {
                change: this._refresh
            },
            'usersChart combo[name=scale]': {
                change: this._refresh
            },
            'usersChart button[action=refresh]': {
                click: this._refresh
            }
        });
    },
    
    _init: function(widget)
    {
        widget.down("combo[name=scale]").setValue("day");
        widget.down("datefield[name=from]").setValue(Ext.Date.getFirstDateOfMonth(new Date()));
        widget.down("datefield[name=to]").setValue(Ext.Date.getLastDateOfMonth(new Date()));      
    	this._refresh(widget.down("button[action=refresh]"));
    },
    
    _refresh: function(source)
    {
    	var widget = source.up("panel");
    	var scale = widget.down("combo[name=scale]").getValue(); 
    	var from = widget.down("datefield[name=from]").getValue();
    	var to = widget.down("datefield[name=to]").getValue();

    	if(scale && from && to)
		{
            var store = Ext.data.StoreManager.lookup('Registrations');
            store.load({
                params: {
                    scale: scale,
                    from: Ext.Date.format(from, 'Y-m-d'),
                    to: Ext.Date.format(to, 'Y-m-d')                	
                }        	
            });
		}
    }
    
    
});