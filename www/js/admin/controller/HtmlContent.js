Ext.define('Loto.controller.HtmlContent', {
    extend: 'Ext.app.Controller',
    views: [ 'HtmlContentList', 'HtmlContent' ],
    models: [ 'HtmlContent' ],
    stores: [ 'HtmlContent' ],

    init: function() {
        this.control({
            'htmlContentList': {
            	selectionchange: this._select
            },
            'htmlContentList button[action=add]': {
                click: this._add
            },
            'htmlContentList button[action=copy]': {
                click: this._copy
            },
            'htmlContent button[action=close]': {
                click: this._close
            },
            'htmlContent button[action=delete]': {
                click: this._delete
            },
            'htmlContent button[action=save]': {
                click: this._save
            }
        });
    },
    

    _select: function(selection, rows)
    {
        var content = selection.selected.first();
        if(content)
        {
            var details = selection.view.up("tabpanel").down("htmlContent");
            details.show();
            details.getForm().loadRecord(content);
        }
    },

    _copy: function(btn)
    {
        var content = btn.up("htmlContentList").getSelectionModel().selected.first();
        btn.up("htmlContentList").getSelectionModel().deselectAll();
        if(content)
        {
            var details = btn.up("tabpanel").down("htmlContent");
            details.show();
            details.getForm().loadRecord(content);
            details.down("hidden[name=id]").setValue("");
        }
    },
    
    _add: function(btn)
    {
        var content = btn.up("tabpanel").down("htmlContent");
        content.getForm().reset();
        content.show();
    },
    
    _close: function(btn)
    {
        var content = btn.up("tabpanel").down("htmlContent");
        content.getForm().reset();
        content.hide();
    },
    
    _delete: function(btn)
    {
    	var me = this;
    	var del = btn;
    	var id = btn.up("htmlContent").getForm().getValues().id;
    	var msg = "Вы уверены что хотите удалить блок.<br>Эта операция не может быть отменена."
    	Ext.Msg.confirm('Удаление HTML контента', msg,
           function (btn){
               if(btn == 'yes')
        	   {
            	   Ext.Ajax.request({
            		   url: "/admin/htmlContent/delete/ajax/",
            		   method: 'GET',
            		   params: {id: id},
            		   success: function (result, request) {
            			   Ext.data.StoreManager.lookup('HtmlContent').load();
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
    	btn.up("htmlContent").getForm().submit({
    		url: '/admin/htmlContent/save/ajax/',
    		success: function(form, action) {
    			Ext.data.StoreManager.lookup('HtmlContent').load();
   			    me._close(btn);
    		}
    	});
    }
    
});