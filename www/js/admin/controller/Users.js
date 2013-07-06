Ext.define('Loto.controller.Users', {
    extend: 'Ext.app.Controller',
    views: [ 'Users', 'UsersChart', 'UserDetails' ],
    models: [ 'User', 'Registrations', 'UserDetails' ],
    stores: [ 'User', 'Registrations', 'UserDetails' ],

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
            },
            'users': {
            	selectionchange: this._selectUser
            },
            'userDetails button[action=close]': {
                click: this._closeUser
            },
            'userDetails button[action=delete]': {
                click: this._deleteUser
            },
            'userDetails button[action=save]': {
                click: this._saveUser
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
    },
    
    _selectUser: function(selection, rows)
    {
        var user = selection.selected.first();
        if(user)
        {
            var details = selection.view.up("tabpanel").down("userDetails");
            details.show();
            var userId = user.get("id");
            
            Ext.data.StoreManager.lookup('UserDetails').load({
            	scope: this,
            	params: { id: userId },
            	callback: function(records, operation, success) {
            		var userDetails = records[0];
            		details.getForm().loadRecord(userDetails);
        	    }
            });
        }
    },
    
    _closeUser: function(btn)
    {
        var details = btn.up("tabpanel").down("userDetails").hide();    	
    },
    
    _deleteUser: function(btn)
    {
    	var me = this;
    	var del = btn;
    	var user = btn.up("tabpanel").down("users").getSelectionModel().selected.first();
    	var userName = user.get("login");
    	var userId = user.get("id");
    	var msg = "Вы уверены что хотите удалить пользователя '" + userName + "'.<br>Эта операция не может быть отменена."
    	Ext.Msg.confirm('Удаление пользователя', msg,
           function (btn){
               if(btn == 'yes')
        	   {
            	   Ext.Ajax.request({
            		   url: "/admin/user/delete/ajax/",
            		   method: 'GET',
            		   params: {id: userId},
            		   success: function (result, request) {
            			   Ext.data.StoreManager.lookup('User').load();
            			   me._closeUser(del);
            		   }
            	   });            	   
        	   }
           }
    	);    	
	},
    
    _saveUser: function(btn)
    {
    	btn.up("userDetails").getForm().submit({
    		url: '/admin/user/save/ajax/',
    		success: function(form, action) {
    			debugger;
    		}
    	});
    }
    
});