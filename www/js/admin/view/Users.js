Ext.define('Loto.view.Users', {
	extend: 'Ext.grid.Panel',
	alias: 'widget.users',
    title: 'Пользователи',
    store: 'User',
    stateful: true,
    columns: [
      {
        text     	: 'Дата регистрации',
        dataIndex	: 'created',
        format   	: 'Y-m-d H:i',
        width	 	: 120,
        renderer 	: Ext.util.Format.dateRenderer('Y-m-d H:i')          
      },
      {
        text     	: 'Активность',
        dataIndex	: 'last_seen',
        format   	: 'Y-m-d H:i',
        width	 	: 120,        
        renderer 	: Ext.util.Format.dateRenderer('Y-m-d H:i')          
      },
      {
        text     	: 'Login',
        dataIndex	: 'login'
      },
      {
        text     	: 'Имя',
        dataIndex	: 'first_name',
        flex	 	: 1
      },
      {
          text     	: 'Фамилия',
          dataIndex	: 'last_name',
          flex	 	: 1
      },
      {
        text     	: 'E-mail',
        dataIndex	: 'email',
        flex	 	: 1
      },
      {
          text     	: 'Пригласил',
          dataIndex	: 'referal',
          flex	 	: 1
      }
    ],
    dockedItems: [{
        xtype: 'pagingtoolbar',
        store: 'User',
        dock: 'bottom',
        displayInfo: true
    }]    
 });
