import React from 'react'
import "./Places_Card.css"

const Places_Card = () => {
    return (
        <div>
            <div className="places_container">
        
                <div className="box">
                    <img className='places_img' src="https://images.unsplash.com/photo-1507525428034-b723cf961d3e" alt="sea view" />
                    <div className="card-content">
                        <h1>Sea View</h1>
                        <p>Lorem ipsum dolor sit amet consectetur adipisicing elit. At fugiat quia explicabo odio ab soluta.</p>
                    </div>
                    <div className="places_btn"><a href="">Explore More</a></div>
                </div>
                
                <div className="box">
                    <img className='places_img' src="https://images.unsplash.com/photo-1501785888041-af3ef285b470?auto=format&fit=crop&w=800&q=80" alt="almanzer" />
                    <div className="card-content">
                        <h1>Almanzer</h1>
                        <p>Lorem ipsum dolor sit amet consectetur adipisicing elit. At fugiat quia explicabo odio ab soluta.</p>
                    </div>
                    <div className="places_btn"><a href="">Explore More</a></div>
                </div>
                
                <div className="box">
                    <img className='places_img' src="https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80" alt="badshahi mosque" />
                    <div className="card-content">
                        <h1>Badshahi Mosque</h1>
                        <p>Lorem ipsum dolor sit amet consectetur adipisicing elit. At fugiat quia explicabo odio ab soluta.</p>
                    </div>
                    <div className="places_btn"><a href="">Explore More</a></div>
                </div>

            </div>
        </div>
    )
}

export default Places_Card
