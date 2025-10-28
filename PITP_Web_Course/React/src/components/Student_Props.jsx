import React from 'react'

const Student_Props = (props) => {
  return (
    <div>
      <p>My name is {props.name}</p>
      <p>My Fathers name is {props.fname}</p>
      <p>My Age is {props.age}</p>
      <p>My department is {props.department}</p>
      <p>I got {props.cgpa}</p>
    </div>
  )
}

export default Student_Props
