Ext.define('Loto.controller.Options', {
    extend: 'Ext.app.Controller',
    views: [
        'Options'
    ],

    init: function() {
        this.control({
            'options': {
                render: this._load
            },
            'options button[action=save]': {
                click: this._save
            }
        });
    },
    
    _load: function(options)
    {
        options.getForm().load({
            url: '/admin/options/load/ajax/'
        });
    },
    
    _save: function(btn)
    {
    	var form = btn.up('form').getForm();
	    form.standardSubmit = true;
        if(form.isValid())
        {
        	form.submit({
        		url: '/admin/options/save/'
        	});
        }
    },
    
});    
 