Ext.define('Loto.view.Emails', {
    extend: 'Ext.FormPanel',
    alias: 'widget.emails',
    title: 'Почтовые рассылки',
    frame: true,
    layout: 'anchor',
    defaults: {
    	labelAlign: 'left',
    	labelWidth: 200,
  	  	anchor: '50%'
    },
    defaultType: 'textfield',
    buttonAlign: 'left',
    fileUpload: true,
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
	    	xtype: 'filefield',
	    	fieldLabel: 'HTML шаблон',
		    name: 'template'
	    },
        {
	        xtype: 'htmleditor',
	     	anchor: '100%',	
	        fieldLabel: 'Письмо',
	        name: 'body',
	        height: 400
	    },
    ],
    buttons: [{
    	text: 'Отправить',
    	action: 'send'
    }]
  });
 