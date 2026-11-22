const principal = 1000;
const rate = 8;
const time = 5;

function calculateSimpleInterest(p, r, t){
    const SI = (p * r * t)/100;
    console.log(`Interest: ${SI}, Total: ${p+SI}`);
}

calculateSimpleInterest(principal, rate, time);