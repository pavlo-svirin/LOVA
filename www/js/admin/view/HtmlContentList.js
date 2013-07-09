Ext.define('Loto.view.HtmlContentList', {
	extend: 'Ext.grid.Panel',
	alias: 'widget.htmlContentList',
    store: 'HtmlContent',
    stateful: true,
    tbar: [
       { xtype: 'button', text: 'Добавить', action: 'add' },
       { xtype: 'button', text: 'Копировать', action: 'copy' },
       { 
    	   xtype: 'combo',
    	   name: 'lang',
    	   fieldLabel: 'Язык',
    	   store: 'Languages',
    	   queryMode: 'local',
    	   displayField: 'caption',
    	   valueField: 'code',
    	   emptyText: "--- выберите ---",
    	   labelWidth: 50
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
    	   labelWidth: 60
       }
    ],
    columns: [
        { text: 'Язык', dataIndex: 'lang', width: 100 },
        { text: 'Страница', dataIndex: 'page', width: 100 },
        { text: 'Код', dataIndex: 'code', flex: 1 },
        { text: 'Тип', dataIndex: 'type', width: 100 },
        { 
        	text: 'Котент',
        	dataIndex: 'content',
        	flex: 2,
            renderer: function(value, column, content) {
                if(content.get('type') == "STRING")
                {
                	return value;
                }
            } 
        },
    ]
 });
