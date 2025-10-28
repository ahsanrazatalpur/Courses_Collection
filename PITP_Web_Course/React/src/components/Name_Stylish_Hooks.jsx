import React, {useState} from 'react'
import "./Name_Stylish_Hooks.css"

const Name_Stylish_Hooks = () => {
    const [name, setName] = useState("Name ?")
  return (
    <div>
      <div className="container">
        <h1 className='heading'>Name Changer Game</h1>

            <h1>{name}</h1>
        <button onClick={()=> setName("Ahsan Raza Talpur")}>🪄</button>



      </div>
    </div>
  )
}

export default Name_Stylish_Hooks
