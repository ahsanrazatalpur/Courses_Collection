import React, { useState } from 'react'
import "./Stylish_Counter.css"

const Stylish_Counter = () => {
    const [count , setCount ] = useState(0)
    
  return (
    <div>
      <div className="container">
        <h1>Counter By Ahsan</h1>
    <h1>{count} </h1>
    <div className="btn">
        
    <button onClick={()=> setCount(count + 1)}> ➕</button>
    <button onClick={()=> setCount(count - 1)}>➖</button>
    </div>
      </div>
    </div>
  )
}

export default Stylish_Counter
