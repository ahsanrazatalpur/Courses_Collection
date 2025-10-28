import React from 'react'

const Hero = () => {
    return (
        <div>
            <div className="hero-container">
                <form className='hero-form' action="">
                    <h1>Form</h1>

                    <div className="form-input">
                        <label htmlFor="name">Name : </label>
                        <input type="text" placeholder='Enter your name' name='name' />
                        <label htmlFor="email">Email : </label>
                        <input type="email" name="email" id="email" placeholder='Enter email address' /><br />
                    </div>

                    <div className="form-input">
                        <label htmlFor="password">Password : </label>
                        <input type="password" name="" id="" placeholder='Enter your password' />
                        <label htmlFor="mobile">Phone : </label>
                        <input type="tel" name="mobile" id="mobile" placeholder='Enter you tel number' /><br />
                    </div>

                    <div className="form-input">
                        <label htmlFor="address">Address</label>
                        <textarea name="address" id="address" placeholder='Enter your Address with street number'></textarea>
                        <label htmlFor="gender">Gender : </label>
                        <select name="gender" id="gender">
                            <option value="" selected disabled>Select your gender</option>
                            <option value="male">Male</option>
                            <option value="Female">Female</option>
                            <option value="other">Other</option>
                        </select><br />
                    </div>

                    <button type="submit">Submit</button>
                </form>
            </div>
        </div>
    )
}

export default Hero
