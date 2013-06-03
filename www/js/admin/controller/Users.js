Ext.define('Loto.controller.Users', {
    extend: 'Ext.app.Controller',
    views: [ 'Users', 'UsersChart' ],
    models: [ 'User' ],
    stores: [ 'User' ],

    init: function() {
        this.control({
            'usersChart': {
                render: this._loadMonthData
            },
            'usersChart button[name=month]': {
                click: this._loadMonthData
            },
            'usersChart button[name=year]': {
                click: this._loadYearData
            }
        });
    },
    
    _loadMonthData: function()
    {
    	
    },
    
    _loadYearData: function()
    {
    	
    },
    
});