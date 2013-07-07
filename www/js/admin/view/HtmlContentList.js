Ext.define('Loto.view.HtmlContentList', {
	extend: 'Ext.grid.Panel',
	alias: 'widget.htmlContentList',
    store: 'HtmlContent',
    stateful: true,
    tbar: [
       { xtype: 'button', text: 'Добавить', action: 'add' },
       { xtype: 'button', text: 'Копировать', action: 'copy' }
    ],
    columns: [
        { text: 'Код', dataIndex: 'code', width: 240 },
        { text: 'Язык', dataIndex: 'lang' }
    ]
 });
