Ext.define('Loto.controller.Emails', {
    extend: 'Ext.app.Controller',
    views: [ 'Emails' ],
//    models: [ 'Emails' ],
//    stores: [ 'Emails' ],

    init: function() {
        this.control({
            'emails button[action=send]': {
                click: this._send
            },
            'emails radiogroup': {
            	change: this._toggleRcpts
            }
        });
    },
    
    _send: function(btn) {
    	var form = btn.up('form').getForm();
    	btn.disable();
        if(form.isValid())
        {
        	form.submit({
        		url: '/admin/send/ajax/'
        	});
        }
    }, 
    
    _toggleRcpts: function(grp) {
    	var emails = grp.up('form').down('textfield[name=emails]');
    	if(grp.getValue().rcpt == "all")
		{
    		emails.allowBlank = true;
    		emails.validate();
    		emails.disable();
		}
    	else
		{
    		emails.allowBlank = false;
    		emails.validate();
    		emails.enable();
		}
    }
    
});