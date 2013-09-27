Ext.define('Loto.view.Tickets', {
	extend: 'Ext.grid.Panel',
	title: 'Лотерея - билеты',
	alias: 'widget.tickets',
    store: 'Tickets',
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
        	fieldLabel: 'Созданные с',
        	format: 'Y-m-d',
        	startDay: 1,
        	labelWidth: 80,
        	width: 190
        },
        { 
        	xtype: 'datefield',
        	name: 'to',
        	fieldLabel: 'по',
        	format: 'Y-m-d',
        	startDay: 1,
        	labelWidth: 20,
        	width: 120
        },
        {
        	xtype: 'checkbox',
        	name: 'active',
        	fieldLabel: 'Только активные',
        	checked: true,
        	margin: "0 0 0 10"
        },
        {
        	xtype: 'checkbox',
        	name: 'paid',
        	fieldLabel: 'Только оплаченные',
        	checked: true,
        	width: 150,
        	labelWidth: 120
        }
	],
    columns: [
        { text: 'Пользователь', dataIndex: 'user_id' },        
        { text: 'Числа', dataIndex: 'numbers', flex: 1 },       
        { text: 'LOVA число', dataIndex: 'lova_number' },       
        { text: 'Игр всего', dataIndex: 'games' },
        { text: 'Игр осталось', dataIndex: 'games_left' },
        { text: 'Создан', dataIndex: 'created', renderer: Ext.util.Format.dateRenderer('Y-m-d H:i') },
        { text: 'Оплачен', dataIndex: 'paid', renderer: Ext.util.Format.dateRenderer('Y-m-d H:i') },
        { text: 'Цена за игру', dataIndex: 'game_price' },
        { text: 'Стоимость билета', dataIndex: 'total' }
    ],
    dockedItems: [{
        xtype: 'pagingtoolbar',
        store: 'Tickets',
        dock: 'bottom',
        displayInfo: true
    }]    
 });
