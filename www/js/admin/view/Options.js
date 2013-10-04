Ext.define('Loto.view.Options', {
    extend: 'Ext.FormPanel',
    alias: 'widget.options',
    title: 'Настройки',
    frame: true,
    autoScroll:true,
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
            },
            {
          	  xtype: 'checkbox',
          	  fieldLabel: 'Случайные числа',
          	  name: 'randomNumbers'
            },
            {
          	  xtype: 'textfield',
          	  fieldLabel: 'Выигрышные числа для следующего розыгрыша',
          	  name: 'luckyNumbers'
            },
            {
        	  xtype: 'textfield',
              fieldLabel: 'LOVA число для следующего розыгрыша',
              name: 'lovaNumber'
            },
            {
                fieldLabel: 'Общий приз',
                name: 'totalWin',
                allowDecimals: true,
                decimalPrecision: 2,
                step: 0.01,
            },
            {
            	  xtype: 'textfield',
            	  fieldLabel: 'Буферное время (мин)',
            	  name: 'bufferTime'
            },
            {
          	  xtype: 'textfield',
          	  fieldLabel: 'Лимит билетов на игру',
          	  name: 'ticketsLimit'
            },
            {
                fieldLabel: 'Максимальное LOVA число',
                name: 'maxLovaNumber'
            },
            {
                fieldLabel: 'Сумма для Призового билета',
                name:'amountForPrizeTicket',
                decimalPrecision: 2,
                step: 0.01
            },
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
          title: 'Бюджет',
          autoHeight: true,
          width: 600,
          layout: 'column',
          defaults: {
          	layout: 'form',
          	width: 500,
          	minValue: 0,
          	maxValue: 100,
          	tipText: function(thumb)
          	{
          		return String(thumb.value) + '%';
          	},
          },
          defaultType: 'sliderfield',
          items: [
            {
              fieldLabel: 'Приз',
              name: 'budgetPrize',
            },
            {
              xtype: 'label',
              name: 'budgetPrize',
              width: 50,
              margin: '0 0 0 15'
            },
            {
                fieldLabel: 'Фонд',
                name: 'budgetFond'
             },
             {
                xtype: 'label',
                name: 'budgetFond',
                width: 50,
                margin: '0 0 0 15'
            },
            {
                fieldLabel: 'Подарочные билеты',
                name: 'budgetGift'
             },
             {
                xtype: 'label',
                name: 'budgetGift',
                width: 50,
                margin: '0 0 0 15'
            },
            {
                fieldLabel: 'Балы',
                name: 'budgetBonus'
            },
            {
                xtype: 'label',
                name: 'budgetBonus',
                width: 50,
                margin: '0 0 0 15'
            },
            {
              fieldLabel: 'Затраты',
              name: 'budgetCosts'
            },
            {
              xtype: 'label',
              name: 'budgetCosts',
              width: 50,
              margin: '0 0 0 15'
            },
            {
              fieldLabel: 'Прибыль',
              name: 'budgetProfit'
            },
            {
              xtype: 'label',
              name: 'budgetProfit',
              width: 50,
              margin: '0 0 0 15'
            }
          ]
      },
      {
          xtype:'fieldset',
          title: 'Начисления Пользователям за покупки Рефералов',
          collapsible: false,
          autoHeight: true,
          width: 600,
          defaults: {
          	allowBlank: false
          },
          defaultType: 'numberfield',
          items: [
            {
              fieldLabel: 'С Основного счета (%)',
              name: 'refPersonal',
            },
            {
              fieldLabel: 'С Фонда (%)',
              name: 'refFond',
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
 
