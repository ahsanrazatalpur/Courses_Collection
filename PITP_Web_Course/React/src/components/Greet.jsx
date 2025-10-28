import React from 'react'

const Greet = () => {
    let name  = "Ahsan Raza"
    return (
    <div>
        {/* Always make variable outside of return and inside of function and use it in {} */}
      <h1>Hi, There How Are you {name}</h1>
    </div>
  )
}

export default Greet
