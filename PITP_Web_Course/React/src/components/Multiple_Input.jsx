
import React , {useState} from 'react'

const Multiple_Input = () => {
    function Multiple_Input(){

        const [input , setInputs] = useState({})

        const handleChange = (e) =>{
            const name = e.target.name;
            const value = e.target.value;
             setInputs(values => ({...values, [name]: value}))

        }

        }
    }
  return (
    <div>
      
      <h2>Form</h2>

      <form action="">
      <label htmlFor="first-name">First name</label>
      <input type="text" placeholder='Enter Your Name'  onChange={submitchange}/>

      <label htmlFor="last-name">Last Name</label>
      <input type="text"  placeholder='Enter Your Last Name' onChange={submitchange}/>

      <p>First name {input.firstname} and Last name {input.lastname}</p>
      
      
      </form>
    </div>
  )


export default Multiple_Input
























// import { useState } from 'react';

// function MultipleInput() {
//   const [inputs, setInputs] = useState({});

//   const handleChange = (e) => {
//     const name = e.target.name;
//     const value = e.target.value;
//     setInputs(values => ({...values, [name]: value}))
//   }

//   return (
//     <form>
//       <label>First name:
//       <input type="text" name="firstname" value={inputs.firstname} 
//       onChange={handleChange}/>
//       </label><br></br><br></br>
//       <label>Last name:
//       <input type="text" name="lastname" value={inputs.lastname} 
//       onChange={handleChange} />


//       </label>
//       <p>Current values: {inputs.firstname} {inputs.lastname}</p>
//     </form>
//   )
// }
// export default MultipleInput;