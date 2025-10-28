import React from 'react'
import  "./Form.css"
const Form = () => {

    function showdata(){
       let email  =  document.getElementById('email').value;
       let password = document.getElementById('password').value;
       alert(`From DataBase <br /> Your name is ${email} and your password is ${password}`)
    }


  return (
    <div>
      <form action="">
        <h1>Login</h1>
        <input className='email' type="email" name="email" id="email" placeholder='Email' />  <br />
        <input type="password" name="password" id="password"  placeholder='Password'/> <br />
        <button onClick={showdata} className='password' type="submit">Submit</button>
      </form>
    </div>
  )
}

export default Form
