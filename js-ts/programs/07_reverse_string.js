function reverseString(string){
  let reveresedString = '';
  for(let i = string.length; i > 0; i--){
    reveresedString = reveresedString + string[i-1];
  }

  return reveresedString;
}


const result = reverseString('inahp');
console.log(result);