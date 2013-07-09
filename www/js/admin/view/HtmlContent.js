Ext.define('Loto.view.HtmlContent', {
	extend: 'Ext.form.Panel',
	alias: 'widget.htmlContent',
    frame: true,
    height: 400,
    autoScroll:true,
    bodyPadding: 10,
    layout: 'anchor',
	defaults: {
		anchor: '100%'
	},
	defaultType: 'textfield',
    hidden: true,
    tbar: [
        { xtype: 'button', text: 'Сохранить', action: 'save' },        
        { xtype: 'button', text: 'Удалить', action: 'delete' },        
        { xtype: 'button', text: 'Закрыть', action: 'close' }
    ],
    items: [
        { name: 'id', xtype: 'hidden' },
        { 
     	   xtype: 'combo',
     	   name: 'lang',
     	   fieldLabel: 'Язык',
     	   store: 'Languages',
     	   queryMode: 'local',
     	   displayField: 'caption',
     	   valueField: 'code',
     	   emptyText: "--- выберите ---",
        },
        { 
     	   xtype: 'combo',
     	   name: 'page',
     	   fieldLabel: 'Страница',
     	   store: 'Pages',
     	   queryMode: 'local',
     	   displayField: 'caption',
     	   valueField: 'code',
     	   emptyText: "--- выберите ---",
        },        
        { name: 'code', fieldLabel: 'Код' },
        { name: 'type', fieldLabel: 'Тип' },
        { xtype: 'htmleditor', name: 'content', fieldLabel: 'Содержание', height: 300 }

    ]    
});
