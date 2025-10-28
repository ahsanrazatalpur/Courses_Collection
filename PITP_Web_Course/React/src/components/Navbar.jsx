import React from 'react';
import "./Navbar.css";



const Navbar = () => {
  return (
    <div>
    <div className="navbar">
        <div className="nav-brand">My Website</div>
        <div className="nav_links">
            <a href="">Home</a>
            <a href="">About</a>
            <a href="">Service</a>
            <a href="">Contact</a>
        </div>
    </div>
    </div>
  )
}

export default Navbar;
