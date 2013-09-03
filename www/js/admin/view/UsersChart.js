Ext.define('Loto.view.UsersChart', {
	extend: 'Ext.panel.Panel',
	alias: 'widget.usersChart',
    title: 'График регистраций',
    height: '600',
    tbar: [
        { 
        	xtype: 'combo',
        	name: 'scale',
        	fieldLabel: 'Масштаб',
        	allowBlank: false,
            displayField: 'caption',
            valueField: 'name',
            autoSelect: true,
        	labelWidth: 60,
        	width: 160,
        	store: Ext.create('Ext.data.Store', {
        		fields: [ 'name', 'caption' ],
        		data: [
    		        { name: 'day', caption: 'День' },
    		        { name: 'week', caption: 'Неделя' },
    		        { name: 'month', caption: 'Месяц' },
    		        { name: 'year', caption: 'Год' }    		        
        		]
        	})
        },
        { 
        	xtype: 'datefield',
        	name: 'from',
        	fieldLabel: 'Период с',
        	format: 'Y-m-d',
        	startDay: 1,
        	labelWidth: 60,
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
        },
        { 
        	xtype: 'button',
        	action: 'refresh',
        	text: 'Обновить'
        }
    ],    
    items: [
      {
    	xtype: 'chart',
    	store: 'Registrations',
    	animate: false,
        style: 'background:#fff',
        theme: 'Blue',
        width: 1000,
        height: 200,
        layout: 'fit',
    	axes:[
				{
					type:"Numeric",
					position:"left",
					fields:["registered", "activated", "referals"],
					grid: true,
					minimum:0,
					minorTickSteps: 1
				},
				{
					type:"Category",
					position:"bottom",
					fields:["date"]
				}
			],
			series:[
				{
					type:"line",
					axis:"left",
					xField:"date",
					yField:["registered"],
		            tips: {
		                trackMouse: true,
		                width: 160,
		                height: 65,
		                renderer: function(storeItem, item) {
		                  this.setTitle(
		                      storeItem.get('date')
		                      + '<br>'
		                      + 'Зарегистрировано: '
		                      + storeItem.get('registered')
		                      + "<br>"
		                      + 'Активировано: '
		                      + storeItem.get('activated')
		                      + "<br>"
		                      + 'Рефералов: '
		                      + storeItem.get('referals')
		                  );
		                }
   	                }				
				},
				{
					type:"line",
					axis:"left",
					xField:"date",
					yField:["activated"],
		            tips: {
		                trackMouse: true,
		                width: 160,
		                height: 65,
		                renderer: function(storeItem, item) {
		                  this.setTitle(
		                      storeItem.get('date')
		                      + '<br>'
		                      + 'Зарегистрировано: '
		                      + storeItem.get('registered')
		                      + "<br>"
		                      + 'Активировано: '
		                      + storeItem.get('activated')
		                      + "<br>"
		                      + 'Рефералов: '
		                      + storeItem.get('referals')
		                  );
		                }
   	                },
   	                style: {
   	                	stroke: '#ff0000',
   	                	'stroke-width': 1,
   	                	opacity: 0.6
   	            	}   	               
				},
				{
					type:"column",
					axis:"left",
					highlight: true,
					xField:"date",
					yField:["referals"],
			     	style: {
			            opacity: 0.5
			        }				
				}
			]
    	
      },
      {
    	  xtype: 'grid',
    	  store: 'Registrations',
    	  columns: [
    	      { text : 'Период', dataIndex: 'date', flex: 1 },
    	      { text : 'Зарегистрировано', dataIndex: 'registered', flex: 1 },
    	      { text : 'Активировано', dataIndex: 'activated', flex: 1 },
    	      { text : 'Рефералов', dataIndex: 'referals', flex: 1 }
    	  ]
      }
	]
 });
