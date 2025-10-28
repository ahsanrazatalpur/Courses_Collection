import React from 'react';

const Component = () => {
  return (
    <div>
      <h1>React Components</h1>
      <p>Components are pieces of code that can be reused.</p>

      <h2>1. Functional Component</h2>
      <pre>{`
function Welcome() {
  return (
    <h1>Hello There</h1>
  );
}`}</pre>

      <h2>2. Arrow Function Component</h2>
      <pre>{`
const App = () => {
  return (
    <h1>Content</h1>
  );
}`}</pre>

      <h2>3. Class-based Component</h2>
      <pre>{`
import React, { Component } from "react";

class Welcome extends Component {
  render() {
    return <h1>Hello, {this.props.name}</h1>;
  }
}`}</pre>
    </div>
  );
};

export default Component;
