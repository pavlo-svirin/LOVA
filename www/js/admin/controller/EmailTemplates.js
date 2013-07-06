Ext.define('Loto.controller.EmailTemplates', {
    extend: 'Ext.app.Controller',
    views: [ 'EmailTemplates', 'EmailTemplate' ],
    models: [ 'EmailTemplate' ],
    stores: [ 'EmailTemplate' ],

    init: function() {
        this.control({
            'emailTemplates': {
            	selectionchange: this._select
            },
            'emailTemplates button[action=add]': {
                click: this._add
            },
            'emailTemplate button[action=close]': {
                click: this._close
            },
            'emailTemplate button[action=delete]': {
                click: this._delete
            },
            'emailTemplate button[action=save]': {
                click: this._save
            }
        });
    },
    

    _select: function(selection, rows)
    {
        var template = selection.selected.first();
        if(template)
        {
            var details = selection.view.up("tabpanel").down("emailTemplate");
            details.show();
            details.getForm().loadRecord(template);
        }
    },

    _add: function(btn)
    {
        var tmpl = btn.up("tabpanel").down("emailTemplate");
        tmpl.getForm().reset();
        tmpl.show();
    },
    
    _close: function(btn)
    {
        var tmpl = btn.up("tabpanel").down("emailTemplate");
        tmpl.getForm().reset();
        tmpl.hide();
    },
    
    _delete: function(btn)
    {
    	var me = this;
    	var del = btn;
    	var id = btn.up("emailTemplate").getForm().getValues().id;
    	var msg = "Вы уверены что хотите удалить шаблон.<br>Эта операция не может быть отменена."
    	Ext.Msg.confirm('Удаление шаблона', msg,
           function (btn){
               if(btn == 'yes')
        	   {
            	   Ext.Ajax.request({
            		   url: "/admin/emailTemplate/delete/ajax/",
            		   method: 'GET',
            		   params: {id: id},
            		   success: function (result, request) {
            			   Ext.data.StoreManager.lookup('EmailTemplate').load();
            			   me._close(del);
            		   }
            	   });            	   
        	   }
           }
    	);    	
	},
    
    _save: function(btn)
    {
    	var me = this;
    	btn.up("emailTemplate").getForm().submit({
    		url: '/admin/emailTemplate/save/ajax/',
    		success: function(form, action) {
    			Ext.data.StoreManager.lookup('EmailTemplate').load();
   			    me._close(btn);
    		}
    	});
    }
    
});