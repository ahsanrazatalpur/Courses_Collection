const startButton = document.getElementById('start-btn')
const nextButton = document.getElementById('next-btn')

const questionContainerElement = document.getElementById('question-container')
const questionElement = document.getElementById('question')
const answerButtonElement = document.getElementById('answer-buttons')

let shuffleQuestions,currentQuestionIndex;
let quizScore = 0;


function startGame(){
    startButton.classList.add('hide')
    shuffleQuestions.sort(() =>{Math.random() -0.5
        currentQuestionIndex = 0;
        questionContainerElement.classList.remove('hide')
        setnextQuestion()
    })
}


function setnextQuestion{
    resetState();
    showQuestion(ShadowRoot(currentQuestionIndex))
}


function showQuestion(question){
    question.Element.innerText = question.question;
    question.answers.forEach(answers)=>{
        const button = document.createElement('button')
        button.innerText = answerButtonElement.corect
    }
    button.addEventlistner('click', selectAnswer)
    answerButtonElement.appendChild(button)
}



function resetState(){
    ClearStatusClass(document.body)
    nextButton.classList.add('hide')
   while(answerButtonElement.firstChild){
    answerButtonElement.removeChild(answerButtonElement.firstChild)
   }
}



function selectAnswer(e){
    const selectedButton = e.target
    const correct = selectedButton.dataset.correct

    SetStatusClass(document.body , correct)
    Array.from(answerButtonElement.children).forEach(button)=>{
        SetStatusClass(button, button.dataset.correct)
    
    }
}
if (shuffleQuestions.length > currentQuestionIndex + 1){
    nextButton.classList.remove("hide")}
else{
    startButton.innerText = "restart"
    startButton.classList.remove('hide')
}

if(selectedButton.dataset = corect){
    quizScore ++

}
document.getElementById('right-answers').innerHTML=quizScore



function SetStatusClass(element, correct){
    ClearStatusClass(element)
    if(correct){
        element.classList.add("correct")
    
    }else{
         element.classList.add("wrong")
    }
}


function ClearStatusClass(elements){
    elements.classList.remove('corect')
    elements.classList.remove('wrong')
}



const questions = [
    {
        question : 'Which one of these is Javascript framework?',
        answers :[
            
            {text : 'Python', correct : false},
            {text : 'Django', correct : false},
            {text : 'React', correct : true},
            {text : 'Eclippse', correct : false},
        ],

    },
    {
        question : 'Who is the prime minister of Pakistan ?',
        answers :[
            
            {text : 'Imran Khan', correct : false},
            {text : 'Nawaz Sharees', correct : false},
            {text : 'Bilawal Bhutto', correct : false},
            {text : 'Shahbaz Shareef', correct : true},
        ],

    },
    {
        question : 'What is 100-100+100 ?',
        answers :[
            
            {text : '0', correct : false},
            {text : '100', correct : true},
        ],

    },

]