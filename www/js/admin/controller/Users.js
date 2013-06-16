Ext.define('Loto.controller.Users', {
    extend: 'Ext.app.Controller',
    views: [ 'Users', 'UsersChart' ],
    models: [ 'User' ],
    stores: [ 'User' ],

    init: function() {
        this.control({
            'usersChart': {
                render: this._init
            },
            'usersChart button[name=month]': {
                click: this._loadMonthData
            },
            'usersChart button[name=year]': {
                click: this._loadYearData
            }
        });
    },
    
    _init: function(widget)
    {
        var store = Ext.data.StoreManager.lookup('User');
        store.load({
    		scope: this,
        	callback: function(records, operation, success) {
            	var total = store.count();
            	widget.down('label[name=total]').setText(total);

            	var today = 0;
            	store.each(function(user){
            		var now = new Date();
            		var midgnight = new Date(1900 + now.getYear(), now.getMonth(), now.getDate());
            		var registerDay = user.get('created');
        			if(registerDay.getTime() >= midgnight.getTime())
        			{
        				today++;
        			}
            	});
            	widget.down('label[name=today]').setText(today);
        	}
        });
    	
    	this._loadMonthData();
    },
    
    _loadMonthData: function()
    {
    	
    },
    
    _loadYearData: function()
    {
    	
    },
    
});