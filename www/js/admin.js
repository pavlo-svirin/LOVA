Ext.Loader.setConfig({enabled:true});
Ext.application({
    name: 'Loto',
    appFolder: '/js/admin',
    controllers: [
      'Options',
      'Users',
      'Emails',
      'EmailTemplates'
    ],
    launch: function()
    {
        Ext.create('Ext.container.Viewport', {
            layout: 'card',
            items: [{
                xtype: 'tabpanel',
                renderTo: 'admin-screen',
                activeTab: 0,
                frame: true,
                items: [
                    { xtype: 'options' },
    	            { 
                    	title: 'Пользователи',
                    	layout: {
                    	    type  : 'vbox',
                    	    align : 'stretch',
                    	    pack  : 'start'
                    	},                    	
                		items: [
	                      { xtype: 'users', flex: 1 },
	                      { xtype: 'userDetails' }
	                    ]
    	            },
    	            { xtype: 'usersChart' },
    	            { xtype: 'emails' },
    	            { 
                    	title: 'Шаблоны почты',
                    	layout: {
                    	    type  : 'vbox',
                    	    align : 'stretch',
                    	    pack  : 'start'
                    	},                    	
                		items: [
	                      { xtype: 'emailTemplates', flex: 1 },
	                      { xtype: 'emailTemplate' }
	                    ]
    	            }
                ]
            }]
        });
    }
});
