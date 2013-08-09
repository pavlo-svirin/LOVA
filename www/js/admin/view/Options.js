Ext.define('Loto.view.Options', {
    extend: 'Ext.FormPanel',
    alias: 'widget.options',
    title: 'Настройки',
    frame: true,
    fieldDefaults: {
    	labelAlign: 'left',
    	labelWidth: 200,
    	anchor: '100%'
    },
    defaultType: 'textfield',
    buttonAlign: 'left',
    items: [
      {
        xtype:'fieldset',
        title: 'Настройки',
        collapsible: false,
        autoHeight: true,
        width: 600,
        defaults: {
        	minValue: 0,
        	maxValue: 100,
        	allowBlank: false
        },
        defaultType: 'numberfield',
        items: [
          {
	        xtype: 'textfield',
	        fieldLabel: 'Пароль администратора',
	        name: 'adminPassword'
		  },
          {
		        xtype: 'textfield',
		        fieldLabel: 'Путь к .htpasswd',
	        	name: 'htpasswdPath'
		  },
          {
        	name: 'rateFond',
            fieldLabel: 'Сумма начисленний за каждого участника системы',
            allowDecimals: true,
            decimalPrecision: 6,
            step: 0.001
          },
          {
          	name: 'rateReferal',
              fieldLabel: 'Сумма начисленний за каждого реферала',
              allowDecimals: true,
              decimalPrecision: 6,
              step: 0.001
          },
          {
  	         xtype: 'textfield',
        	 name: 'invitesLimit',
             fieldLabel: 'Ограничение на количество приглашений в час'
          }
        ]
      },
      {
          xtype:'fieldset',
          title: 'Лоттерея',
          collapsible: false,
          autoHeight: true,
          width: 600,
          defaults: {
          	minValue: 0,
          	maxValue: 100,
          	allowBlank: false
          },
          defaultType: 'numberfield',
          items: [
            {
              fieldLabel: 'Количество чисел',
              name: 'maxNumbers',
            },
            {
              fieldLabel: 'Максимальное число',
              name: 'maxNumber',
            },
            {
              fieldLabel: 'Стоимость 1 игры (ПЕ)',
              name: 'gamePrice',
              allowDecimals: true,
              decimalPrecision: 1,
              step: 0.1,
            },
            {
              fieldLabel: 'Максимальное количество игр',
              name: 'maxGames',
            }
          ]
      },      
      {
          xtype:'fieldset',
          title: 'Лайки',
          collapsible: false,
          autoHeight: true,
          width: 600,
          defaults: {
          	minValue: 0,
          	allowBlank: false
          },
          items: [
              {
      	        xtype: 'textfield',
      	        fieldLabel: 'Лайков',
      	        name: 'like',
      	        readOnly: true
      	      },
              {
        	        xtype: 'numberfield',
        	        fieldLabel: 'Пользователей надо',
        	        name: 'likeRequired'
    	      }
          ]
      },
      {
        xtype:'fieldset',
        title: 'Расписание начислений',
        collapsible: false,
        autoHeight: true,
        width: 600,
        layout: 'column',
        defaults: {
        	labelWidth: 90,
        	allowBlank: true,
        	layout: 'form',
        	width: 150
        },
        items: [
          {
            xtype: 'checkbox',
            fieldLabel: 'понедельник',
            name: 'scheduleMonday'
          },
          {
            xtype: 'checkbox',
            fieldLabel: 'вторник',
            name: 'scheduleTuesday'
          },
          {
            xtype: 'checkbox',
            fieldLabel: 'среда',
            name: 'scheduleWednesday'
          },
          {
            xtype: 'checkbox',
            fieldLabel: 'четверг',
            name: 'scheduleThursday'
          },
          {
            xtype: 'checkbox',
            fieldLabel: 'пятница',
            name: 'scheduleFriday'
          },
          {
            xtype: 'checkbox',
            fieldLabel: 'суббота',
            name: 'scheduleSaturday'
          },
          {
            xtype: 'checkbox',
            fieldLabel: 'воскресенье',
            name: 'scheduleSunday'
          },
          {
            xtype: 'textfield',
            fieldLabel: 'время',
            name: 'scheduleTime'
          }
        ]
      },
      {
    	  xtype:'fieldset',
    	  title: 'Содержание',
    	  collapsible: false,
    	  autoHeight: true,
    	  width: 600,
    	  defaults: {
          	labelWidth: 90,
          	allowBlank: false
    	  },
    	  items: [
	          {
	              xtype: 'textarea',
	              fieldLabel: 'Контент',
	              name: 'contentRu',
	              height: 100
	          }
    	  ]
      }
    ],
    buttons: [{
    	text: 'Сохранить',
    	action: 'save'
    }]
  });
 