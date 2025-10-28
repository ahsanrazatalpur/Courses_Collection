import React, { useState } from 'react'

const Name_Hooks = () => {
    const [name , setName] = useState("Name")
  return (
    <div>
        <h1>{name}</h1>
        <button onClick={()=> setName("Ahsan raza")}>?</button>
      
    </div>
  )
}

export default Name_Hooks
