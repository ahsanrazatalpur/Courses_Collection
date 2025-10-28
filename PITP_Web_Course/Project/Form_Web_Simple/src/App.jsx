import React from 'react'
import "./index.css"
import Navbar from './components/Navbar'
import Hero from './components/Hero'
import About from './About'
import Services from './Services'
import Contact from './Contact'


const App = () => {
  return (
    <div>
      <Navbar/>
      <Hero/>
      <About/>
      <Services/>
      <Contact/>
    </div>
  )
}

export default App
