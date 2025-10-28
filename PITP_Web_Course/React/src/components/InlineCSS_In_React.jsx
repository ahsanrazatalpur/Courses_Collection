import React from 'react'

const InlineCSS_In_React = () => {
  return (
    <div>
      <style>
        {`
        body{
        background-color  :red ; 
    
        }
        p{
        color :white;}
        `}
      </style>
        <p>Here is example of inline css </p>
    </div>
  )
}

export default InlineCSS_In_React
