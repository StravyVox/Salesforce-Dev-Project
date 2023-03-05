var mapElements = new Map();
function showForm(){
    var form = document.getElementsByClassName('form-block')[0];
    var infoBlock = document.getElementsByClassName('info-block')[0];
    infoBlock.style.display = 'none';
    form.style.display = 'flex';
    prepareForm();
}
function Validate(){
    let controlPoint = true;
    mapElements.forEach(element=>{
        if(element === false){
            controlPoint = false;
        }
    })
    if(controlPoint){
        let button = document.getElementById('submitButton');
        button.style.display = 'block';
    }
    else{
        let button = document.getElementById('submitButton');
        button.style.display = 'none';
    }
}
function prepareMap(inputelements){
    for(let element of inputelements){
        mapElements.set(element.id,false);
    }
    mapElements.set('captcha', false);

}
function prepareForm(){
    var form = document.getElementsByClassName('form')[0];
    let button = document.getElementById('submitButton');
    button.style.display = 'none';
    var inputelements = form.getElementsByClassName('formInput');
    prepareMap(inputelements);
    inputelements[0].addEventListener('change',CheckText);
    inputelements[1].addEventListener('change',CheckName);
    inputelements[2].addEventListener('change',CheckName);
    inputelements[3].addEventListener('change',CheckMail);
    inputelements[4].addEventListener('change',CheckPhone);
    inputelements[5].addEventListener('change',CheckText);
    
}
function recaptchaCallback(){
    mapElements.set('captcha', true);

    Validate();
}
function CheckPhone(event){
    let regexp = /\+?[0-9]+\b/
    if(regexp.test(event.target.value)){
        mapElements.set(event.target.id,true);
        event.target.style.border = '0px red';
    }
    else{
        mapElements.set(event.target.id,false);
        event.target.style.border = 'solid red';
        event.target.value = '';
        event.target.placeholder = 'Phone should have only numbers';
    }
    Validate();
}
function CheckMail(event){
    var regexp = /^[\w]+@[A-z09]+\.[A-z]+/
    if(regexp.test(event.target.value)){
        mapElements.set(event.target.id,true);
        event.target.style.border = '0px red';
    }
    else{
        mapElements.set(event.target.id,false);
        event.target.style.border = 'solid red';
        event.target.value = '';
        event.target.placeholder = 'Like example@company.ex';
    }
    Validate();
}
function CheckText(event){
    var regexp = /[\w]+\b/
    if(regexp.test(event.target.value)){
        mapElements.set(event.target.id,true);
        event.target.style.border = '0px red';
    }
    else{
        mapElements.set(event.target.id,false);
        event.target.style.border = 'solid red';
        event.target.value = '';
        event.target.placeholder = 'Should have some text';
    }
    Validate();
}
function CheckName(event){
    var regexp = /^[A-z]+\b/
    if(regexp.test(event.target.value)){
        mapElements.set(event.target.id,true);
        event.target.style.border = '0px red';
    }
    else{
        mapElements.set(event.target.id,false);
        event.target.style.border = 'solid red';
        event.target.value = '';
        event.target.placeholder = 'Only symbols';
    }
    Validate();
}

