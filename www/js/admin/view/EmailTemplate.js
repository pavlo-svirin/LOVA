Ext.define('Loto.view.EmailTemplate', {
	extend: 'Ext.form.Panel',
	alias: 'widget.emailTemplate',
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
        { name: 'code', fieldLabel: 'Код' },
        { name: 'lang', fieldLabel: 'Язык' },
        { name: 'subject', fieldLabel: 'Тема' },
        { xtype: 'textarea', name: 'body', fieldLabel: 'Текст', height: 200 }

    ]    
});
