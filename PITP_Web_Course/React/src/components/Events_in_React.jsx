import React from 'react'
import "./Events_in_React.css"

const Events_in_React = () => {
    function Output() {
        alert("Hi There how are you!")
    }

    function onSubmitExample(){
        alert(` ${name} and ${age}`);
    }

    function mounse_enter_example(){
        alert("Mouse is Hovering on me YAHOOO!!!!")
    }
    return (
        <div>
            <style>
                {`
                
.btn_greet{
  color: red;
  padding: 0.5rem 1rem;
  border-radius: 10px;
  transition: transform 0.3s ease-in;
  margin: 200px;
  margin
  background: linear-gradient(45deg, red, blue);
}

.btn_greet:hover {
  transform: scale(1.1);
  cursor: pointer;
}

}
               `}
            </style>

            {/* Events are action that happend on browser that can be handle by eventhandler
      Some event handlers are
      onClick
      inSubmit
      onChange
      onMouseEnter
       */}


{/* onclick event listner example */}
            <button className='btn_greet' onClick={Output}>Greet</button>

{/* onsubmit event listener example */}
            <form action="" onSubmit={onSubmitExample}>
                <input type="text" placeholder='Enter Name?' />
                <input type="text" placeholder='Enter Age' />
            <button type="submit">Submit</button>
            </form>

{/* Hover me event listener example */}
<div className='hover_me' onMouseEnter={mounse_enter_example}>Hover Me</div>

        </div>
    )
}

export default Events_in_React
