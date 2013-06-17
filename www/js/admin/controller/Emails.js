Ext.define('Loto.controller.Emails', {
    extend: 'Ext.app.Controller',
    views: [ 'Emails' ]

    init: function() {
        this.control({
            'emails button[action=send]': {
                click: this._send
            },
            'emails combo[name=rcpt]': {
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
    
    _toggleRcpts: function(rcpt) {
    	var emails = rcpt.up('form').down('textfield[name=emails]');
    	if(rcpt.getValue() == "list")
		{
    		emails.allowBlank = false;
    		emails.validate();
    		emails.enable();
		}
    	else
		{
    		emails.allowBlank = true;
    		emails.validate();
    		emails.disable();
		}
    }
    
});