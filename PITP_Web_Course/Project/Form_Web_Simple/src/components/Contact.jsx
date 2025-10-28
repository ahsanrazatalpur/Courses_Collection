import React from 'react'

const Contact = () => {
  return (
    <div>
      <div className="contact-container">
        <h2>Contact Us</h2>
        <form className="contact-form">
          <div className="contact-content">
            <label htmlFor="fullname">Full Name : </label>
            <input type="text" id="fullname" name="fullname" placeholder="Enter your full name" required />

          </div>

          <div className="contact-content">
            <label htmlFor="email">Email : </label>
            <input type="email" name="email" id="email" placeholder='Enter your email' />

          </div>
          <div className="contact-content">

            <label htmlFor="message">Message : </label>
            <textarea name="" id="" placeholder='Enter your message'></textarea>
          </div>
          <button className='send-message'>Send Message</button>
        </form>
      </div>
    </div>
  )
}

export default Contact
