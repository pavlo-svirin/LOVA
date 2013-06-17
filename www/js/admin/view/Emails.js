Ext.define('Loto.view.Emails', {
    extend: 'Ext.FormPanel',
    alias: 'widget.emails',
    title: 'Почтовые рассылки',
    frame: true,
    fieldDefaults: {
    	labelAlign: 'left',
    	labelWidth: 200,
  	    width: 600
    },
    defaultType: 'textfield',
    buttonAlign: 'left',
    items: [
        {
        	xtype: 'combo',
        	fieldLabel: 'Получатель',
        	queryMode: 'local',
        	name: 'rcpt',
            displayField: 'caption',
            valueField: 'inputValue',
            autoSelect: true,
	        allowBlank: false,
	        editable: false,
            store: Ext.create('Ext.data.Store', {
                fields: ['caption', 'inputValue'],
                data : [
                    { caption: 'Указанный адрес', inputValue: 'list' },
                    { caption: 'Подписчики', inputValue: 'subscribers'},
                    { caption: 'Все пользователи', inputValue: 'all'}
                ]
            })
        },
        {
	        xtype: 'textfield',
	        fieldLabel: 'E-mail разделеные запятой',
	        name: 'emails',
	        disabled: true
	    },
        {
	        xtype: 'textfield',
	        fieldLabel: 'Тема',
	        name: 'subject',
	        allowBlank: false
	    },
        {
	        xtype: 'htmleditor',
	        fieldLabel: 'Письмо',
	        name: 'body',
	        width: 800,
	        height: 300,
	        allowBlank: false
	    },
    ],
    buttons: [{
    	text: 'Отправить',
    	action: 'send'
    }]
  });
 