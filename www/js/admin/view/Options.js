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
        	name: 'revenueUser',
            fieldLabel: 'Сумма начисленний за каждого участника системы',
            allowDecimals: true,
            decimalPrecision: 2,
            step: 0.01
          },
          {
          	name: 'revenueReferal',
              fieldLabel: 'Сумма начисленний за каждого реферала',
              allowDecimals: true,
              decimalPrecision: 2,
              step: 0.01
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
            name: 'scheduleWendesday'
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

    ],
    buttons: [{
    	text: 'Сохранить',
    	action: 'save'
    }]
  });
 