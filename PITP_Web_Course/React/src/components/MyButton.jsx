function MyButton({value}){
    return(
<>
{/* I didnot give the value of button here because it is Javascript base function only i donot import react here so i will
give value to the parent component App.jsx so to be render on browser */}
<button>{value}</button>

</>
    )
}
export default MyButton