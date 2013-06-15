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
        	xtype: 'radiogroup',
        	fieldLabel: 'Получатель',
        	columns: 2,
        	items: [
                { boxLabel: 'Указанный адрес', name: 'rcpt', inputValue: 'list' },
                { boxLabel: 'Все пользователи', name: 'rcpt', inputValue: 'all', checked: true},
        	]
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
 