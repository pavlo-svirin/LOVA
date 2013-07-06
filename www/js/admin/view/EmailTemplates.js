Ext.define('Loto.view.EmailTemplates', {
	extend: 'Ext.grid.Panel',
	alias: 'widget.emailTemplates',
    store: 'EmailTemplate',
    stateful: true,
    tbar: [
       { xtype: 'button', text: 'Добавить', action: 'add' },
       { xtype: 'button', text: 'Копировать', action: 'copy' }
    ],
    columns: [
        { text: 'Код', dataIndex: 'code', width: 240 },        
        { text: 'Язык', dataIndex: 'lang', width: 240 },       
        { text: 'Тема', dataIndex: 'subject', flex: 1 }
    ]
 });
