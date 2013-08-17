Ext.define('Loto.view.Games', {
	extend: 'Ext.grid.Panel',
	title: 'Лотерея - игры',
	alias: 'widget.games',
    store: 'Games',
    stateful: true,
    tbar : [
        { 
        	xtype: 'button',
        	action: 'refresh',
        	text: 'Обновить'
        },
        { 
        	xtype: 'datefield',
        	name: 'from',
        	fieldLabel: 'Дата от',
        	format: 'Y-m-d',
        	startDay: 1,
        	labelWidth: 50,
        	width: 160
        },
        { 
        	xtype: 'datefield',
        	name: 'to',
        	fieldLabel: 'по',
        	format: 'Y-m-d',
        	startDay: 1,
        	labelWidth: 20,
        	width: 120
        }
	],
    columns: [
        { text: '#', dataIndex: 'id'},        
        { text: 'Дата', dataIndex: 'date', renderer: Ext.util.Format.dateRenderer('Y-m-d H:i') },       
        { text: 'Числа', dataIndex: 'lucky_numbers', flex: 1 },
        { text: 'Билетов', dataIndex: 'tickets' },
        { text: 'Пользователей', dataIndex: 'users' },
        { text: 'Сумма', dataIndex: 'sum' }
    ],
    dockedItems: [{
        xtype: 'pagingtoolbar',
        store: 'Tickets',
        dock: 'bottom',
        displayInfo: true
    }]    
 });
