function sumOfDigits(n){
    let number = n;
    let sum = 0;
    while(number > 0){
        let remainder = number % 10;
        let divider = Math.floor(number / 10);
        sum = sum + remainder;
        number = divider
    }

  return sum;
  
}

const result = sumOfDigits(235);
console.log(result);