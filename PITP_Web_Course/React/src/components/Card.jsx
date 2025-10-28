import React from 'react'
import "./Card.css"

const Card = () => {
  return (
    <div>
      <div className="container">
        <img className='card_img' src="https://images.unsplash.com/photo-1501785888041-af3ef285b470?auto=format&fit=crop&w=800&q=80" alt="" width={350} height={300} />
        <img className='card_img' src="https://images.unsplash.com/photo-1499346030926-9a72daac6c63?auto=format&fit=crop&w=800&q=80" alt="" width={350} height={300}/>
        <img className='card_img' src="https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80" alt="" width={350} height={300}/>
      </div>
    </div>
  )
}

export default Card
