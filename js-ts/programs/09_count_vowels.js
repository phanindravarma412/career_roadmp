
const vowels = [ 'a', 'e', 'i', 'o', 'u' ];

function countVowels(string){
    let count = 0;
    for(let i=0; i<string.length; i++){
        if(vowels.includes(string[i].toLowerCase())){
            count++;
        }
    }

    return count;
}

const result = countVowels('qwasde');
console.log(result);