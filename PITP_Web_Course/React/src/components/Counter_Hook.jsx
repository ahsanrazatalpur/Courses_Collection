import React, {useState} from 'react'

const Counter_Hook = () => {
    const [counter, setCounter] = useState(0)
  return (
    <div>
      <h1>{counter}</h1>
      <button onClick={()=> setCounter(counter + 1)}>Increement +</button>
      <button onClick={()=> setCounter(counter - 1)}>Decreament -</button>
    </div>
  )
}

export default Counter_Hook
