import { useState } from 'react';

function FormSubmit() {
  const [name, setName] = useState("");

  function handleChange(e) {
    setName(e.target.value);
  }

  function handleSubmit(e) {
    e.preventDefault();
    alert(name);
  }

  return (
    <form onSubmit={handleSubmit}>
      <label>Enter your name:
        <input type="text"  value={name} onChange={handleChange}
        />
      </label>
      <input type="submit" />
    </form>
  )
}
export default FormSubmit;