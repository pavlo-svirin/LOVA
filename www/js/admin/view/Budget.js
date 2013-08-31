Ext.define('Loto.view.Budget', {
	extend: 'Ext.grid.Panel',
	title: 'Лотерея - бюджет',
	alias: 'widget.budget',
    store: 'Budget',
    stateful: true,
    features: [{
        ftype: 'summary'
    }],    
    tbar : [
        { 
        	xtype: 'button',
        	action: 'refresh',
        	text: 'Обновить'
        },
        { 
        	xtype: 'datefield',
        	name: 'from',
        	fieldLabel: 'C',
        	format: 'Y-m-d',
        	startDay: 1,
        	labelWidth: 20,
        	width: 120
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
        { text: 'Игра', dataIndex: 'game_id', flex: 1 },        
        {
        	text: 'Общая сумма',
        	dataIndex: 'sum',
        	flex: 1,
            summaryType: 'sum',
       	  	summaryRenderer: function(value, summaryData, dataIndex) {
       	  		return Ext.util.Format.number(value, '0.00');
       	  	}
        },       
        { 
        	text: 'Приз',
        	dataIndex: 'prize',
        	flex: 1,
            summaryType: 'sum',
        	summaryRenderer: function(value, summaryData, dataIndex) {
        		return Ext.util.Format.number(value, '0.00');
        	}
        },       
        { 
            text: 'Фонд',
            dataIndex: 'fond',
        	flex: 1,
            summaryType: 'sum',
      	  	summaryRenderer: function(value, summaryData, dataIndex) {
      	  		return Ext.util.Format.number(value, '0.00');
      	  	}
        },       
        { 
            text: 'Подарочные билеты',
            dataIndex: 'gift',
        	flex: 1,
            summaryType: 'sum',
            summaryRenderer: function(value, summaryData, dataIndex) {
   		  		return Ext.util.Format.number(value, '0.00');
       	  	}
        },       
        { 
            text: 'Бонусные балы',
            dataIndex: 'bonus',
        	flex: 1,
            summaryType: 'sum',
            summaryRenderer: function(value, summaryData, dataIndex) {
   		  		return Ext.util.Format.number(value, '0.00');
       	  	}
        },       
        { 
            text: 'Затраты',
            dataIndex: 'costs',
        	flex: 1,
            summaryType: 'sum',
            summaryRenderer: function(value, summaryData, dataIndex) {
   		  		return Ext.util.Format.number(value, '0.00');
       	  	}
        },       
        { 
            text: 'Прибыль',
            dataIndex: 'profit',
        	flex: 1,
            summaryType: 'sum',
            summaryRenderer: function(value, summaryData, dataIndex) {
   		  		return Ext.util.Format.number(value, '0.00');
       	  	}
        }       
    ],
    dockedItems: [{
        xtype: 'pagingtoolbar',
        store: 'Budget',
        dock: 'bottom',
        displayInfo: true
    }]    
 });
