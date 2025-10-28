import React, {useState} from 'react'

const Another_Count_Hooks = () => {
    const [count , setCount] = useState(0)
  return (
    <div>
      <h1>{count}</h1>
      <button onClick={()=> setCount(count + 1)}>Increase</button>
      <button onClick={()=> setCount(count - 1)} >Decrease</button>
    </div>
  )
}

export default Another_Count_Hooks
