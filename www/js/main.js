function loginAction()
{
	var loginForm = document.getElementById('loginForm');
	if(loginForm)
	{
		if(loginForm.style.visibility == 'hidden')
		{
			loginForm.style.visibility = 'visible';
		}
		else
		{
			loginForm.submit();
		}
	}
}