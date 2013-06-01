Ext.define('Loto.view.UsersChart', {
	extend: 'Ext.chart.Chart',
	alias: 'widget.usersChart',
    title: 'График регистраций',
    store: 'User',
    animate: true,
    style: 'background:#fff',
    theme: 'Category1',
    width: 800,
    height: 200,
    axes: [
       {
    	   type: 'Numeric',
    	   position: 'left',
    	   fields: ['data1', 'data2'],
    	   title: 'Number of Users',
    	   grid: true
       },
       {
    	   type: 'Category',
    	   position: 'bottom',
    	   fields: ['created'],
    	   title: 'Month of the Year'
       }
    ],
    series: [
        {
	        type: 'column',
	        axis: 'left',
	        xField: 'created',
	        yField: 'id',
	        markerConfig: {
	            type: 'cross',
	            size: 3
	        }
        },
        {
            type: 'line',
            axis: 'left',
            smooth: true,
            fill: true,
            fillOpacity: 0.5,
            xField: 'created',
            yField: 'id'
    	}
    ]
 });
