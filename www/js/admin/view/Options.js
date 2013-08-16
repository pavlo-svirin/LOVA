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
              fieldLabel: 'Стоимость 1 игры',
              name: 'gamePrice',
              allowDecimals: true,
              decimalPrecision: 2,
              step: 0.01,
            },
            {
              fieldLabel: 'Максимальное количество игр',
              name: 'maxGames',
            },
            {
              fieldLabel: 'Максимальное количество билетов',
              name: 'maxTickets',
            }
          ]
      },
      {
          xtype:'fieldset',
          title: 'Расписание розыгрышей',
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
      	      }
          ]
      }
    ],
    buttons: [{
    	text: 'Сохранить',
    	action: 'save'
    }]
  });
 