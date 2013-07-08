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
        { name: 'page', fieldLabel: 'Страница' },
        { name: 'code', fieldLabel: 'Код' },
        { name: 'type', fieldLabel: 'Тип' },
        { name: 'lang', fieldLabel: 'Язык' },
        { xtype: 'htmleditor', name: 'content', fieldLabel: 'Содержание', height: 300 }

    ]    
});
