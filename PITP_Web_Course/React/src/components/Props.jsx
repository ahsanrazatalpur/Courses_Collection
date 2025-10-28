import React from 'react'

const Props = (props) => {
    
  return (
    <div>
      {/* Props are like parameter in function that allow to pass data from one component from another */}

      {/* Eg: Child component and parents is App.jsx */}

      {/* pass props keyword in component function */}
      {/* and use variable like name.props in {} */}
      {/* and in parent component use <Componnet name="Ahsan"/> */}

        <h1>Hi There ,{props.name}</h1>

        {/* string value can be taken as = ""
        and numerical value can be taken as ={} */}

    </div>
  )
}

export default Props
