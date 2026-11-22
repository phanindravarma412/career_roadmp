function reverseString(string){
  let reveresedString = '';
  for(let i = string.length; i > 0; i--){
    reveresedString = reveresedString + string[i-1];
  }

  return reveresedString;
}




function palindrome(string){
  let reveresedString = reverseString(string);

  return string.toLowerCase() === reveresedString.toLowerCase();

}


const result  = palindrome('Madam'); 
console.log(result);