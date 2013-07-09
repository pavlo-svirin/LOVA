Ext.define('Loto.controller.HtmlContent', {
    extend: 'Ext.app.Controller',
    views: [ 'HtmlContentList', 'HtmlContent' ],
    models: [ 'HtmlContent' ],
    stores: [ 'HtmlContent', 'Languages', 'Pages' ],

    init: function() {
        this.control({
            'htmlContentList': {
            	selectionchange: this._select
            },
            'htmlContentList combo': {
            	change: this._load
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
            details.remove(details.down("[name=content]"));
            if(content.get('type') == "HTML")
            {
            	details.add({ xtype: 'htmleditor', name: 'content', fieldLabel: 'Содержание', height: 300 });
            } 
            else
            {
            	details.add({ xtype: 'textfield', name: 'content', fieldLabel: 'Содержание' });            	
            }
            details.doLayout()
            details.show();
            details.getForm().loadRecord(content);
        }
    },

    _load: function(combo)
    {
    	var lang = combo.up("htmlContentList").down("combo[name=lang]").getValue();
    	var page = combo.up("htmlContentList").down("combo[name=page]").getValue();
    	if(lang && page)
    	{
    		Ext.data.StoreManager.lookup('HtmlContent').load({
    			params: { 'lang': lang, 'page': page }
    		});
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
    	var lang = btn.up("tabpanel").down("htmlContentList").down("combo[name=lang]").getValue();
    	var page = btn.up("tabpanel").down("htmlContentList").down("combo[name=page]").getValue();
    	
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
	               			Ext.data.StoreManager.lookup('HtmlContent').load({
	            				params: { 'lang': lang, 'page': page }
	            			});
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
    	var lang = btn.up("tabpanel").down("htmlContentList").down("combo[name=lang]").getValue();
    	var page = btn.up("tabpanel").down("htmlContentList").down("combo[name=page]").getValue();

    	btn.up("htmlContent").getForm().submit({
    		url: '/admin/htmlContent/save/ajax/',
    		success: function(form, action) {
    			Ext.data.StoreManager.lookup('HtmlContent').load({
    				params: { 'lang': lang, 'page': page }
    			});
   			    me._close(btn);
    		}
    	});
    }
    
});