Ext.define('Loto.view.GameDetails', {
	extend: 'Ext.form.Panel',
	alias: 'widget.gameDetails',
    frame: true,
    height: 400,
    autoScroll: true,
    bodyPadding: 10,
    layout: 'column',
	defaults: {
		columnWidth: 0.5,
	},
    hidden: true,
    tbar: [
        { xtype: 'button', text: 'Подвердить', action: 'approve', disabled: true },        
        { xtype: 'button', text: 'Закрыть', action: 'close' }
    ],
    items: [
        {
            xtype:'fieldset',
            frame: false,
            layout: 'anchor',
        	defaults: {
        		anchor: '100%'
        	},
        	items: [
		        {
		            xtype:'fieldset',
		            id: 'budget',
		            title: 'Бюджет',
		            autoHeight: true,
    	            layout: 'column',
		            defaultType: 'sliderfield',
    	        	defaults: {
    	            	labelAlign: 'left',
    	            	labelWidth: 140,
    	            	readOnly: true,
		            	width: 360,
		            	minValue: 0,
		            	maxValue: 100,
		            	tipText: function(thumb) { return String(thumb.value) + '%' }
		            },
		            items: [
		              { name: 'budgetPrize', fieldLabel: 'Приз' },
		              { name: 'budgetPrize', xtype: 'label', width: 80, margin: '0 0 0 15' },
		              { name: 'budgetFond', fieldLabel: 'Фонд' },
		              { name: 'budgetFond', xtype: 'label', width: 80, margin: '0 0 0 15' },
		              { name: 'budgetGift', fieldLabel: 'Подарочные билеты' },
		              { name: 'budgetGift', xtype: 'label', width: 80, margin: '0 0 0 15' },
		              { name: 'budgetBonus', fieldLabel: 'Балы' },
		              { name: 'budgetBonus', xtype: 'label', width: 80, margin: '0 0 0 15' },
		              { name: 'budgetCosts', fieldLabel: 'Затраты' },
		              { name: 'budgetCosts', xtype: 'label', width: 80, margin: '0 0 0 15' },
		              { name: 'budgetProfit', fieldLabel: 'Прибыль' },
		              { name: 'budgetProfit', xtype: 'label', width: 80, margin: '0 0 0 15' }
		            ]
		        },      
		    ]
        },
        {
            xtype:'fieldset',
            frame: false,
            layout: 'anchor',
        	defaults: {
        		anchor: '100%'
        	},
        	items: [
		        {
		            xtype:'fieldset',
		            id: 'prize',
		            title: 'Распределение приза',
		            autoHeight: true,
    	            layout: 'column',
		            defaultType: 'sliderfield',
    	        	defaults: {
    	            	labelAlign: 'left',
    	            	labelWidth: 140,
    	            	readOnly: true,
		            	width: 360,
		            	minValue: 0,
		            	maxValue: 100,
		            	tipText: function(thumb) { return String(thumb.value) + '%' }
		            },
		            items: [
		              { name: 'budgetPrizeSupperWinners', fieldLabel: 'Супер победители' },
		              { name: 'budgetPrizeSupperWinners', xtype: 'label', width: 80, margin: '0 0 0 15' },
		              { name: 'budgetPrizeWinners', fieldLabel: 'Победители' },
		              { name: 'budgetPrizeWinners', xtype: 'label', width: 80, margin: '0 0 0 15' }
	               ]
		        }
        	]
        },
        
        {
        	columnWidth: 1,
        	xtype: 'grid',
        	id: 'winnerTickets',
        	title: 'Билеты - победители',
    	    columns: [
              { header: 'Пользователь',  dataIndex: 'user_id', flex: 1, sortable: false, hideable: false,
            	renderer: function (value) {
            		var user = Ext.data.StoreManager.lookup('User').getById(value);
            		return (user) ? user.get('login') : value;
            	}
              },
              { header: 'Числа', dataIndex: 'numbers', flex: 1, sortable: false, hideable: false  },
              { header: 'LOVA число', dataIndex: 'lova_number', sortable: false, hideable: false,
            	  renderer: function (value, metaData, record) {
            		  if(record.get('lova_number_distance') == record.get('min_lova_distance')) {
            			  metaData.style="font-weight: bold; font-color: white; background-color: green;";
            		  }
            		  return value;

            	  }
              }
    	    ],
        }
        
    ]    
});
