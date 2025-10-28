import React from 'react'

const BioData = () => {

    let name = "Ahsan Raza Talpur"
    let age = 22
    let Department = "Computer Science"

    return (
        <div>
            {/* use <br /> tag for new line */}

            <p>My name is {name} <br /> My age is {age} <br />I study in {Department} </p>
            
        </div>
    )
}

export default BioData;
