Ext.define('Loto.view.UserDetails', {
	extend: 'Ext.form.Panel',
	alias: 'widget.userDetails',
    title: 'Пользователь',
    frame: true,
    height: 400,
    bodyPadding: 10,
    layout: 'column',
    hidden: true,
    tbar: [
        { xtype: 'button', text: 'Сохранить', action: 'save' },        
        { xtype: 'button', text: 'Удалить', action: 'delete' },        
        { xtype: 'button', text: 'Закрыть', action: 'close' }
    ],
    items: [
        {
            xtype:'fieldset',
            title: 'Основные настройки',
        	columnWidth: 0.5,            
            defaultType: 'textfield',
            layout: 'anchor',
        	defaults: {
        		anchor: '100%',
            	labelAlign: 'left',
            	labelWidth: 150
            },
        	items: [
		        { name: 'login', fieldLabel: 'Login', allowBlank: false },
		        { name: 'email', fieldLabel: 'E-mail', allowBlank: false },
		        { name: 'password', fieldLabel: 'Пароль' },
		        { name: 'first_name', fieldLabel: 'Имя', allowBlank: false },
		        { name: 'last_name', fieldLabel: 'Фамилия' }
        	]
        },
        {
            xtype:'fieldset',
            title: 'Профиль',
            defaultType: 'textfield',
        	columnWidth: 0.5,            
            defaults: {
            	anchor: '100%',
            	labelAlign: 'left',
            	labelWidth: 150
            },
            height: 153,
            layout: 'anchor',
        	items: [
		        { name: 'profile.phone', fieldLabel: 'Телефон' },
		        { name: 'profile.country', fieldLabel: 'Страна' },
		        { name: 'profile.skype', fieldLabel: 'Скайп' },
		        { name: 'referal', fieldLabel: 'Пригласил' }
        	]
        },
        {
            xtype:'fieldset',
            title: 'Счет',
            layout: 'anchor',
        	columnWidth: 0.5,            
            defaultType: 'textfield',
        	defaults: {
        		anchor: '100%',
            	labelAlign: 'left',
            	labelWidth: 150
            },
        	items: [
		        { name: 'account.personal', fieldLabel: 'Персональный' },
		        { name: 'account.fond', fieldLabel: 'Фонд' },
		        { name: 'account.referal', fieldLabel: 'Реферальный' },        	        
        	]
        },
        {
            xtype:'fieldset',
            title: 'Информация',
            layout: 'anchor',
        	columnWidth: 0.5,            
            defaultType: 'textfield',
        	defaults: {
        		anchor: '100%',
            	labelAlign: 'left',
            	labelWidth: 150,
            	readOnly: true,
            },
        	items: [
		        { name: 'id', fieldLabel: 'ID' },
		        { name: 'created', fieldLabel: 'Зарегистрирован' },
		        { name: 'last_seen', fieldLabel: 'Активность' },
		        { name: 'profile.validateEmail', fieldLabel: 'Активирован', xtype: 'checkbox' },        	        
		        { name: 'profile.subscribe', fieldLabel: 'Рассылка', xtype: 'checkbox' },
		        { name: 'profile.like', fieldLabel: 'Поставил лайк', xtype: 'checkbox' }
		        //{ name: 'meta.referals', fieldLabel: 'Рефералов' }
        	]
        }
    ]    
});
