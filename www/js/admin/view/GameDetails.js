Ext.define('Loto.view.GameDetails', {
	extend: 'Ext.form.Panel',
	alias: 'widget.gameDetails',
    frame: true,
    height: 300,
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
		            	tipText: function(thumb)
		            	{
		            		return String(thumb.value) + '%';
		            	},
		            },
		            items: [
		              {
		                fieldLabel: 'Приз',
		                name: 'budgetPrize',
		              },
		              {
		                xtype: 'label',
		                name: 'budgetPrize',
		                width: 80,
		                margin: '0 0 0 15'
		              },
		              {
		                  fieldLabel: 'Фонд',
		                  name: 'budgetFond'
		               },
		               {
		                  xtype: 'label',
		                  name: 'budgetFond',
		                  width: 80,
		                  margin: '0 0 0 15'
		              },
		              {
		                  fieldLabel: 'Подарочные билеты',
		                  name: 'budgetGift'
		               },
		               {
		                  xtype: 'label',
		                  name: 'budgetGift',
		                  width: 80,
		                  margin: '0 0 0 15'
		              },
		              {
		                  fieldLabel: 'Балы',
		                  name: 'budgetBonus'
		              },
		              {
		                  xtype: 'label',
		                  name: 'budgetBonus',
		                  width: 80,
		                  margin: '0 0 0 15'
		              },
		              {
		                fieldLabel: 'Затраты',
		                name: 'budgetCosts'
		              },
		              {
		                xtype: 'label',
		                name: 'budgetCosts',
		                width: 80,
		                margin: '0 0 0 15'
		              },
		              {
		                fieldLabel: 'Прибыль',
		                name: 'budgetProfit'
		              },
		              {
		                xtype: 'label',
		                name: 'budgetProfit',
		                width: 80,
		                margin: '0 0 0 15'
		              }
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
        	]
        }
    ]    
});
