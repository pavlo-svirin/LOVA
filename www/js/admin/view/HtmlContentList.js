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
        { text: 'Язык', dataIndex: 'lang', flex: 1 },
        { text: 'Страница', dataIndex: 'page', flex: 1 },
        { text: 'Код', dataIndex: 'code', flex: 1 },
        { text: 'Тип', dataIndex: 'type', flex: 1 }
    ]
 });
